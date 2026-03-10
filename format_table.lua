-- format_table.lua
-- テーブル状のテキストを列幅を揃えて整形するNeovimプラグイン
--
-- コマンド:
--   :FormatTable      -- 区切り文字を自動検出して整形
--   :FormatTable =    -- イコール区切りを強制
--   :FormatTable |    -- マークダウンテーブルを強制
--
-- Visual選択した範囲のみ、またはバッファ全体に適用可能
--
-- FIX IT
-- テーブル外のコメント行などを除外
-- 複数テーブルを検出した場合は、桁数変更で別テーブルとみなす？
-- 予め桁数を揃える必要ある
-- ほぼスペース区切りのみでどんな区切り文字でも整う、少なくとも一つ以上のスペースを含んでる場合は

local M = {}

local DEBUG = true

-- DEBUG=trueのとき :messages にログを出力する
-- @param msg string 表示するメッセージ
local function dbg(msg)
  if DEBUG then
    vim.notify("[FormatTable] " .. msg, vim.log.levels.DEBUG)
  end
end

-- 行群から区切り文字を自動検出する
-- 全非空行のうち過半数が "|" を含む         → マークダウンテーブル "|"
-- 全非空行のうち過半数が " = " を含む        → イコール区切り "="
-- それ以外                                   → スペース区切り " "
-- @param lines string[]  バッファから取得した行の配列
-- @return string  検出した区切り文字 (" " | "=" | "|")
local function detect_sep(lines)
  local pipe_count = 0
  local eq_count = 0
  local total = 0
  for _, line in ipairs(lines) do
    local trimmed = line:match("^%s*(.-)%s*$")
    if trimmed ~= "" then
      total = total + 1
      if trimmed:find("|") then pipe_count = pipe_count + 1 end
      if trimmed:find("%s+=%s+") then eq_count = eq_count + 1 end
    end
  end
  dbg(string.format("detect: total=%d pipe=%d eq=%d", total, pipe_count, eq_count))
  if total == 0 then return " " end
  if pipe_count / total > 0.5 then return "|" end
  if eq_count / total > 0.5 then return "=" end
  return " "
end

-- 1行を指定の区切り文字で分割し、各フィールドをトリムして返す
-- sep=" "  : 連続空白で分割 (先頭・末尾の空白は無視)
-- sep="|"  : パイプで囲まれたマークダウン形式を分割、空フィールドは除外
-- sep="="  : 最初の " = " で左辺・右辺の2フィールドに分割
-- @param line string  処理対象の1行
-- @param sep  string  区切り文字 (" " | "=" | "|")
-- @return string[]  フィールドの配列
local function split_fields(line, sep)
  local fields = {}
  if sep == " " then
    for field in line:gmatch("%S+") do
      table.insert(fields, field)
    end
  elseif sep == "|" then
    -- | a | b | c | の形式: 先頭・末尾のパイプを除去してから分割
    local s = line:match("^%s*|?(.-)%s*|?%s*$") or line
    for field in (s .. "|"):gmatch("(.-)%s*|") do
      local f = field:match("^%s*(.-)%s*$")
      if f ~= "" then
        table.insert(fields, f)
      end
    end
  elseif sep == "=" then
    -- 最初の " = " で lhs / rhs に2分割
    local lhs, rhs = line:match("^(.-)%s+=%s+(.-)%s*$")
    if lhs and rhs then
      table.insert(fields, lhs:match("^%s*(.-)%s*$"))
      table.insert(fields, rhs:match("^%s*(.-)%s*$"))
    else
      -- "=" が前後スペースなし等のfallback: スペース分割
      for field in line:gmatch("%S+") do
        table.insert(fields, field)
      end
    end
  end
  return fields
end

-- UTF-8文字列の表示幅を返す (全角=2, 半角=1)
-- vim.fn.strdisplaywidth() はtabstop設定の影響を受けるため自前実装。
-- UTF-8バイト列をデコードしてUnicodeコードポイントを求め、
-- CJK・ひらがな・カタカナ・絵文字等のブロックに該当すれば幅2、それ以外は幅1とする。
-- Lua5.1はビット演算子非対応のため、AND・左シフトを算術演算で代替している。
-- @param s string  対象文字列
-- @return number  表示幅 (半角単位)
local function strwidth(s)
  local width = 0
  local i = 1
  local bytes = {s:byte(1, #s)}

  -- Lua5.1互換: ビットAND
  local function band(a, b)
    local r, m = 0, 2^31
    repeat
      local ra, rb = a >= m and 1 or 0, b >= m and 1 or 0
      r = r + (ra == 1 and rb == 1 and m or 0)
      a, b = a - ra * m, b - rb * m
      m = m / 2
    until m < 1
    return r
  end

  -- Lua5.1互換: 左シフト (a << n)
  local function lshift(a, n) return a * (2^n) end

  while i <= #bytes do
    local b = bytes[i]
    local codepoint
    if b < 0x80 then
      -- 1バイト: ASCII
      codepoint = b
      i = i + 1
    elseif b < 0xE0 then
      -- 2バイト: ラテン拡張など
      codepoint = lshift(band(b, 0x1F), 6) + band(bytes[i+1], 0x3F)
      i = i + 2
    elseif b < 0xF0 then
      -- 3バイト: ひらがな・カタカナ・CJK漢字など
      codepoint = lshift(band(b, 0x0F), 12) + lshift(band(bytes[i+1], 0x3F), 6) + band(bytes[i+2], 0x3F)
      i = i + 3
    else
      -- 4バイト: 絵文字・CJK拡張Bなど
      codepoint = lshift(band(b, 0x07), 18) + lshift(band(bytes[i+1], 0x3F), 12) + lshift(band(bytes[i+2], 0x3F), 6) + band(bytes[i+3], 0x3F)
      i = i + 4
    end
    -- 全角Unicodeブロック判定
    if (codepoint >= 0x1100 and codepoint <= 0x115F)   -- ハングル字母
    or (codepoint >= 0x2E80 and codepoint <= 0x303F)   -- CJK部首・記号
    or (codepoint >= 0x3040 and codepoint <= 0x33FF)   -- ひらがな〜CJK互換
    or (codepoint >= 0x3400 and codepoint <= 0x4DBF)   -- CJK拡張A
    or (codepoint >= 0x4E00 and codepoint <= 0x9FFF)   -- CJK統合漢字
    or (codepoint >= 0xA000 and codepoint <= 0xA4CF)   -- 彝文字
    or (codepoint >= 0xAC00 and codepoint <= 0xD7AF)   -- ハングル音節
    or (codepoint >= 0xF900 and codepoint <= 0xFAFF)   -- CJK互換漢字
    or (codepoint >= 0xFE10 and codepoint <= 0xFE1F)   -- 縦書き形
    or (codepoint >= 0xFE30 and codepoint <= 0xFE4F)   -- CJK互換形
    or (codepoint >= 0xFF00 and codepoint <= 0xFF60)   -- 全角英数
    or (codepoint >= 0xFFE0 and codepoint <= 0xFFE6)   -- 全角記号
    or (codepoint >= 0x1F300 and codepoint <= 0x1F9FF) -- 絵文字
    or (codepoint >= 0x20000 and codepoint <= 0x2A6DF) -- CJK拡張B
    then
      width = width + 2
    else
      width = width + 1
    end
  end
  return width
end

-- 全行・全列を走査して、各列の最大表示幅を求める
-- @param rows string[][]  split_fields の結果の配列
-- @return number[]  列インデックスをキーとする最大幅の配列
local function col_widths(rows)
  local widths = {}
  for _, row in ipairs(rows) do
    for i, field in ipairs(row) do
      widths[i] = math.max(widths[i] or 0, strwidth(field))
    end
  end
  return widths
end

-- 文字列 s を表示幅 w になるようにスペースで右パディングする
-- マルチバイト文字はバイト数と表示幅が異なるため strwidth() で計算する
-- @param s string  対象文字列
-- @param w number  目標表示幅
-- @return string  パディング済み文字列
local function pad(s, w)
  local sw = strwidth(s)
  return s .. string.rep(" ", math.max(0, w - sw))
end

-- パース済みの行データを整形された文字列に変換する
-- sep=" " : フィールドを2スペースで連結、末尾スペース除去
-- sep="|" : マークダウン形式 "| a | b | c |" に整形
-- sep="=" : "lhs = rhs" 形式に整形 (lhsのみ列幅を揃える)
-- @param rows   string[][]  フィールドの2次元配列
-- @param widths number[]    列ごとの最大表示幅
-- @param sep    string      区切り文字
-- @return string[]  整形済み行の配列
local function format_rows(rows, widths, sep)
  local lines = {}
  for _, row in ipairs(rows) do
    local line
    if sep == "|" then
      local parts = {}
      for i, field in ipairs(row) do
        table.insert(parts, pad(field, widths[i] or strwidth(field)))
      end
      line = "| " .. table.concat(parts, " | ") .. " |"
    elseif sep == "=" then
      local lhs = pad(row[1] or "", widths[1] or 0)
      local rhs = row[2] or ""
      line = lhs .. " = " .. rhs
    else
      local parts = {}
      for i, field in ipairs(row) do
        table.insert(parts, pad(field, widths[i] or strwidth(field)))
      end
      line = table.concat(parts, "  ")
    end
    -- 末尾スペース除去
    table.insert(lines, line:match("^(.-)%s*$"))
  end
  return lines
end

-- プラグインのメイン処理
-- 指定範囲の行を取得→区切り文字決定→パース→幅計算→整形→バッファ書き戻し
-- @param opts_sep   string|nil  強制する区切り文字。nilなら自動検出
-- @param start_line number      処理開始行 (0-indexed)
-- @param end_line   number      処理終了行 (0-indexed, exclusive)
function M.format_table(opts_sep, start_line, end_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local raw_lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
  dbg(string.format("processing %d lines [%d, %d)", #raw_lines, start_line, end_line))

  local sep
  if opts_sep and opts_sep ~= "" then
    sep = opts_sep
    dbg("separator forced = '" .. sep .. "'")
  else
    sep = detect_sep(raw_lines)
    dbg("separator detected = '" .. sep .. "'")
  end

  -- 空行をスキップしながらパース、line_map で元行番号を記憶
  local rows = {}
  local line_map = {}
  for i, line in ipairs(raw_lines) do
    local trimmed = line:match("^%s*(.-)%s*$")
    if trimmed ~= "" then
      local fields = split_fields(line, sep)
      dbg(string.format("  line %d: %d fields: [%s]", i, #fields, table.concat(fields, ", ")))
      if #fields > 0 then
        table.insert(rows, fields)
        table.insert(line_map, i)
      end
    end
  end

  local widths = col_widths(rows)
  dbg("column widths: " .. table.concat(widths, ", "))

  local formatted = format_rows(rows, widths, sep)

  -- 空行はそのまま残し、非空行だけを置き換える
  local new_lines = vim.deepcopy(raw_lines)
  for j, fmt in ipairs(formatted) do
    new_lines[line_map[j]] = fmt
  end

  vim.api.nvim_buf_set_lines(bufnr, start_line, end_line, false, new_lines)
  dbg("done")
end

-- :FormatTable コマンドを登録する
-- range=true により Visual選択範囲や :N,M FormatTable の形式を受け付ける
-- opts.range==0 のときはバッファ全体を対象にする
vim.api.nvim_create_user_command("FormatTable", function(opts)
  local sep = opts.args ~= "" and opts.args or nil
  if sep == "\\|" then sep = "|" end

  local start_line, end_line
  if opts.range > 0 then
    -- Visual選択 or 行指定 (Vim 1-indexed → nvim API 0-indexed)
    start_line = opts.line1 - 1
    end_line   = opts.line2
    dbg(string.format("range mode: line1=%d line2=%d", opts.line1, opts.line2))
  else
    start_line = 0
    end_line   = vim.api.nvim_buf_line_count(0)
    dbg("whole buffer mode")
  end

  M.format_table(sep, start_line, end_line)
end, {
  nargs = "?",
  range = true,  -- E481を解消: rangeを受け付ける
  desc = "Format aligned table. Args: (none)=auto, ==equals, |=markdown",
})

return M

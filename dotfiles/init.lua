-- ~/.config/nvim/init.lua

----------------------------
-- 基本設定
----------------------------
-- インデント２文字
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- プログラミング言語は4文字インデント
local programming_filetypes = {
  'python',
  'c',
  'cpp',
  'javascript',
  'typescript',
  'go',
  'rust',
  'php',
  'lua',
  'sh'
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = programming_filetypes,
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end
})

-- 検索関連
vim.o.ignorecase = true       -- 小文字と大文字を区別しない
vim.o.smartcase = true        -- 大文字が含まれる場合、区別する
vim.o.incsearch = true        -- インクリメンタルサーチ
vim.o.hlsearch = true         -- 検索結果のハイライト
-- 一時的にハイライトを無効化`:nohls`

-- 行末の空白を表示
vim.o.list = true
vim.o.listchars = "space:·,tab:→→"

-- ステータスラインの表示
vim.o.showmode = false        -- モード表示を無効化（lualine等のプラグインに任せる）
vim.o.laststatus = 3          -- 常にステータスラインを表示

-- カーソルライン表示
vim.o.cursorline = true
--vim.o.cursorcolumn = true

-- 挿入モード中はカーソルラインを非表示
vim.api.nvim_create_autocmd('InsertEnter', {
  pattern = '*',
  command = 'set nocursorline',
})
-- ノーマルモード中にカーソルラインを表示
vim.api.nvim_create_autocmd('InsertLeave', {
  pattern = '*',
  command = 'set cursorline',
})

-----------------------------------------------------------------------------
-- キーマップ
-- 基本キーAlt
-----------------------------------------------------------------------------
-- ターミナル開く
vim.api.nvim_set_keymap('n', '<A-t>', ':split term://bash<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-v>', ':vsplit term://bash<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-[>', [[<C-\><C-n>]], {noremap = true}) -- ノーマルモードに戻る

-- CTRL-Rを使ってレジスタの内容を貼り付け
vim.api.nvim_set_keymap('t', '<C-R>', [[<C-\><C-N>"'.nr2char(getchar()).'pi']], {noremap = true, expr = true})

-- ALT+{h,j,k,l}を使ってどのモードからでもウィンドウを移動
vim.api.nvim_set_keymap('t', '<A-h>', [[<C-\><C-N><C-w>h]], {noremap = true})
vim.api.nvim_set_keymap('t', '<A-j>', [[<C-\><C-N><C-w>j]], {noremap = true})
vim.api.nvim_set_keymap('t', '<A-k>', [[<C-\><C-N><C-w>k]], {noremap = true})
vim.api.nvim_set_keymap('t', '<A-l>', [[<C-\><C-N><C-w>l]], {noremap = true})
vim.api.nvim_set_keymap('t', '<A-c>', [[<C-\><C-N><C-w>c]], {noremap = true})
vim.api.nvim_set_keymap('i', '<A-h>', [[<C-\><C-N><C-w>h]], {noremap = true})
vim.api.nvim_set_keymap('i', '<A-j>', [[<C-\><C-N><C-w>j]], {noremap = true})
vim.api.nvim_set_keymap('i', '<A-k>', [[<C-\><C-N><C-w>k]], {noremap = true})
vim.api.nvim_set_keymap('i', '<A-l>', [[<C-\><C-N><C-w>l]], {noremap = true})
vim.api.nvim_set_keymap('i', '<A-c>', [[<C-\><C-N><C-w>c]], {noremap = true})
vim.api.nvim_set_keymap('n', '<A-h>', [[<C-w>h]], {noremap = true})
vim.api.nvim_set_keymap('n', '<A-j>', [[<C-w>j]], {noremap = true})
vim.api.nvim_set_keymap('n', '<A-k>', [[<C-w>k]], {noremap = true})
vim.api.nvim_set_keymap('n', '<A-l>', [[<C-w>l]], {noremap = true})
vim.api.nvim_set_keymap('n', '<A-c>', [[<C-w>c]], {noremap = true})

-- リサイズ
vim.api.nvim_set_keymap('n', '<A-=>', ':resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-->', ':resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-]>', ':vertical resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-[>', ':vertical resize -2<CR>', { noremap = true, silent = true })

-- システムへコピー・ペースト
vim.api.nvim_set_keymap('v', '<A-y>', '"+y', { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '<A-p>', '"+p', { noremap = true, silent = false })
vim.api.nvim_set_keymap('i', '<A-p>', '<C-r>+', { noremap = true, silent = false })

-- 選択部分のbashコマンド実行
vim.api.nvim_set_keymap('v', '<A-r>', ':!bash<CR>', { noremap = true, silent = false })

-- 全選択
vim.api.nvim_set_keymap('n', '<A-a>', 'ggVG', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<A-a>', '<Esc>ggVG', { noremap = true, silent = true })

-- 上下に空白行を挿入（カーソル位置はそのまま）
vim.api.nvim_set_keymap('n', '<A-o>', 'o<Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-O>', 'O<Esc>', { noremap = true, silent = true })

-- 保存と終了
vim.api.nvim_set_keymap('n', '<A-w>', ':w<CR>', { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', '<A-q>', ':q<CR>', { noremap = true, silent = false })

------------------
-- スクリプト
------------------
-- テンキーモードの切り替え----------
-- | 7 | 8 | 9 |       | 7 | 8 | 9 |
-- | u | i | o | <==>  | 4 | 5 | 6 |
-- | j | k | l |       | 1 | 2 | 3 |
-- | m | , | . |       | 0 | , | . |
--
function numpad_mode()
  if vim.b.numpad_mode then
    -- マッピングを解除
    vim.b.numpad_mode = false
    vim.api.nvim_del_keymap('i', 'u')
    vim.api.nvim_del_keymap('i', 'i')
    vim.api.nvim_del_keymap('i', 'o')
    vim.api.nvim_del_keymap('i', 'j')
    vim.api.nvim_del_keymap('i', 'k')
    vim.api.nvim_del_keymap('i', 'l')
    vim.api.nvim_del_keymap('i', 'm')
    vim.o.statusline = "Numpad: OFF"
  else
    vim.b.numpad_mode = true
    -- テンキーモードのキーリマッピング（挿入モード）
    vim.api.nvim_set_keymap('i', 'u', '4', { noremap = true, silent = false })
    vim.api.nvim_set_keymap('i', 'i', '5', { noremap = true, silent = false })
    vim.api.nvim_set_keymap('i', 'o', '6', { noremap = true, silent = false })
    vim.api.nvim_set_keymap('i', 'j', '1', { noremap = true, silent = false })
    vim.api.nvim_set_keymap('i', 'k', '2', { noremap = true, silent = false })
    vim.api.nvim_set_keymap('i', 'l', '3', { noremap = true, silent = false })
    vim.api.nvim_set_keymap('i', 'm', '0', { noremap = true, silent = false })
    vim.o.statusline = "Numpad: ON"
  end
end

-- ノーマルモードで Alt + N を押したときにテンキーモードを切り替える
vim.api.nvim_set_keymap('i', '<A-n>', '<ESC>:lua numpad_mode()<CR>a', { noremap = true, silent = false })


-- ノーマルモードに戻ったときIMEをオフにする -----
function turn_off_ime()
  local status = vim.fn.system("fcitx5-remote")

  if status:match("2") then
    print("IME turned off")
    vim.fn.system("fcitx5-remote -c")
  end
end

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    turn_off_ime()
  end
})


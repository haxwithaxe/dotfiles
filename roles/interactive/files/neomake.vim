autocmd VimEnter * call neomake#configure#automake('nrw', 10)
let g:neomake_python_enabled_makers = ['python', 'pep257', 'flake8']

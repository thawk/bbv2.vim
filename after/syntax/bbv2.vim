" Vim syntax file
" Language: bbv2 (specifically boost jam)
" Original Maintainer: Markus Peloquin <markus@cs.wisc.edu>
" Original URL: http://www.cs.wisc.edu/~markus
"
" let g:bbv2_fold_enable before to enable syntax fold
"
if exists("b:current_syntax")
	finish
endif

let s:cpo_sav = &cpo
set cpo&vim

if has('folding') && get(g:, 'bbv2_fold_enable', 0)
	setlocal foldmethod=syntax
endif

" Remove any old syntax stuff hanging around
setlocal iskeyword +=-

sy clear

sy case match

sy keyword bbv2Cond	if else for switch
sy keyword bbv2Label	case default
sy keyword bbv2Key	actions all in include local module on rule return
sy keyword bbv2Action	bind existing import ignore piecemeal quietly rule
sy keyword bbv2Action	together updated

" Builtin rules
sy keyword bbv2Builtin	ALWAYS BACKTRACE CALLER_MODULE DELETE_MODULE
sy keyword bbv2Builtin	DEPENDS ECHO EXIT EXPORT FAIL_EXPECTED GLOB
sy keyword bbv2Builtin	IMPORT INCLUDES ISFILE LEAVES LOCATE MATCH NOCARE
sy keyword bbv2Builtin	NOTFILE NOUPDATE RMOLD RULENAMES SEARCH SHELL
sy keyword bbv2Builtin	TEMPORARY VARNAMES UPDATE W32_GETREG
sy keyword bbv2Builtin	W32_GETREGNAMES

" Jambase rules
sy keyword bbv2Rule As Bulk Cc C++ Chmod Clean FDefines File Fincludes
sy keyword bbv2Rule Fortran FQuote GenFile HardLink HdrRule InstallBin
sy keyword bbv2Rule InstallLib InstallMan InstallShell Lex Library
sy keyword bbv2Rule LibraryFromObjects Link LinkLibraries Main
sy keyword bbv2Rule MainFromObjects MakeLocate MkDir Object ObjectC++Flags
sy keyword bbv2Rule ObjectCcFlags ObjectDefines ObjectHdrs Objects RmTemps
sy keyword bbv2Rule Setuid SoftLink SubDir SubDirC++Flags SubDirCcFlags
sy keyword bbv2Rule SubDirHdrs SubInclude Shell Undefines UserObject Yacc
" in project.jam
sy keyword bbv2Rule glob glob-tree glob-ex glob-tree-ex conditional option
sy keyword bbv2Rule use-packages

" Jambase pseudotargets
sy keyword bbv2Pseudo alias build-project clean dirs exe file install lib
sy keyword bbv2Pseudo obj shell uninstall use-project using
sy keyword bbv2Pseudo convert generate hdrrule install lib link-directory 
sy keyword bbv2Pseudo make message notfile symlink update variant 
" in project.jam
sy keyword bbv2Pseudo constant path-constant explicit always


" Variables
" $(XX), where XX contains no " character
sy match bbv2Var '\$([^)"]*)'
" $XX where XX does not start with a ( and contains no space, ", or \
sy match bbv2Var '\$[^( \t"\\][^ \t"\\]*'
" <XX> (a feature)
sy match bbv2Var '<[^>]*>'


" Strings
" (there are no special escapes like \x01 or \n)
sy match bbv2StringSpecial "\\." contained
sy cluster bbv2StringElement contains=bbv2StringSpecial,bbv2Var
sy region bbv2String matchgroup=bbv2StringStartEnd start='\(\\\)\@<!"' end='"' skip='\\.' contains=@bbv2StringElement


" Comments
" (only comments [by bjam standards] if they follow whitespace)
sy match bbv2Comment "\([ \t]\|^\)#.*" contains=bbv2Todo,bbv2Var,bbv2String
sy keyword bbv2Todo TODO FIXME XXX contained

" Block
sy region bbv2Block start="{" end="}" transparent fold

" Errors
" semicolons can't be preceded or followed by anything but whitespace
sy match bbv2SemiError "\( \|\t\|\n\)\@<!;"
sy match bbv2SemiError ";\( \|\t\|\n\)\@!"
" colons must either have whitespace on both sides (separating clauses of
" rules) or on neither side (e.g. <variant>release:<define>NDEBUG)
sy match bbv2ColonError "[^ \t]:[ \t]"hs=s+2
sy match bbv2ColonError "[ \t]:[^ \t]"he=e-2


if !exists("did_jamstyle_syntax_inits")
	let did_jamstyle_syntax_inits = 1

	hi link bbv2SemiError bbv2Error
	hi link bbv2ColonError bbv2Error

	hi link bbv2Cond Conditional
	hi link bbv2Label Label
	hi link bbv2Key Keyword
	hi link bbv2Action Keyword
	hi link bbv2Builtin Keyword

	hi link bbv2Rule Keyword
	hi link bbv2Pseudo Keyword

	hi link bbv2Var Identifier

	hi link bbv2String String
	hi link bbv2StringSpecial Special

	hi link bbv2Comment Comment
	hi link bbv2Todo Todo

	hi link bbv2Error Error
endif

let b:current_syntax = "bbv2"

let &cpo = s:cpo_sav
unlet! s:cpo_sav


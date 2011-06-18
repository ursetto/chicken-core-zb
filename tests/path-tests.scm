(use files)

(assert (equal? "/" (pathname-directory "/")))
(assert (equal? "/" (pathname-directory "/abc")))
(assert (equal? "abc" (pathname-directory "abc/")))
(assert (equal? "abc" (pathname-directory "abc/def")))
(assert (equal? "abc" (pathname-directory "abc/def.ghi")))
(assert (equal? "abc" (pathname-directory "abc/.def.ghi")))
(assert (equal? "abc" (pathname-directory "abc/.ghi")))
(assert (equal? "/abc" (pathname-directory "/abc/")))
(assert (equal? "/abc" (pathname-directory "/abc/def")))
(assert (equal? "/abc" (pathname-directory "/abc/def.ghi")))
(assert (equal? "/abc" (pathname-directory "/abc/.def.ghi")))
(assert (equal? "/abc" (pathname-directory "/abc/.ghi")))
(assert (equal? "q/abc" (pathname-directory "q/abc/")))
(assert (equal? "q/abc" (pathname-directory "q/abc/def")))
(assert (equal? "q/abc" (pathname-directory "q/abc/def.ghi")))
(assert (equal? "q/abc" (pathname-directory "q/abc/.def.ghi")))
(assert (equal? "q/abc" (pathname-directory "q/abc/.ghi")))

(define-syntax test
  (syntax-rules ()
    ((_ expected exp)
     (let ((result exp)
	   (expd expected))
       (unless (equal? result expd)
	 (error "test failed" result expd 'exp))))))

(test "./" (normalize-pathname "" 'unix))
(test ".\\" (normalize-pathname "" 'windows))
(test "\\..\\" (normalize-pathname "/../" 'windows))
(test "\\." (normalize-pathname "/abc/../." 'windows))
(test "/." (normalize-pathname "/" 'unix))
(test "/." (normalize-pathname "/./" 'unix))
(test "/." (normalize-pathname "/." 'unix))
(test "./" (normalize-pathname "./" 'unix))
(test "a" (normalize-pathname "a"))
(test "a/" (normalize-pathname "a/" 'unix))
(test "a/b" (normalize-pathname "a/b" 'unix))
(test "a/b" (normalize-pathname "a\\b" 'unix))
(test "a\\b" (normalize-pathname "a\\b" 'windows))
(test "a\\b" (normalize-pathname "a/b" 'windows))
(test "a/b/" (normalize-pathname "a/b/" 'unix))
(test "a/b/" (normalize-pathname "a/b//" 'unix))
(test "a/b" (normalize-pathname "a//b" 'unix))
(test "/a/b" (normalize-pathname "/a//b" 'unix))
(test "/a/b" (normalize-pathname "///a//b" 'unix))
(test "c:a\\b" (normalize-pathname "c:a/./b" 'windows))
(test "c:/a/b" (normalize-pathname "c:/a/./b" 'unix))
(test "c:a\\b" (normalize-pathname "c:a/./b" 'windows))
(test "c:b" (normalize-pathname "c:a/../b" 'windows))
(test "c:\\b" (normalize-pathname "c:\\a\\..\\b" 'windows))
(test "a/b" (normalize-pathname "a/./././b" 'unix))
(test "a/b" (normalize-pathname "a/b/c/d/../.." 'unix))
(test "a/b/" (normalize-pathname "a/b/c/d/../../" 'unix))
(test "../../foo" (normalize-pathname "../../foo" 'unix))
(test "c:\\." (normalize-pathname "c:\\" 'windows))

(define home (get-environment-variable "HOME"))

(test (string-append home "/foo") (normalize-pathname "~/foo" 'unix))
(test "c:~/foo" (normalize-pathname "c:~/foo" 'unix))
(test (string-append home "\\foo") (normalize-pathname "c:~\\foo" 'windows))

(assert (directory-null? "/.//"))
(assert (directory-null? ""))
(assert (not (directory-null? "//foo//")))

(test '(#f "/" (".")) (receive (decompose-directory "/.//")))
(test '(#f "\\" (".")) (receive (decompose-directory (normalize-pathname "/.//" 'windows))))
(test '(#f "/" #f) (receive (decompose-directory "///\\///")))
(test '(#f "/" ("foo")) (receive (decompose-directory "//foo//")))
(test '(#f "/" ("foo" "bar")) (receive (decompose-directory "//foo//bar")))
(test '(#f #f (" " "foo" "bar")) (receive (decompose-directory " //foo//bar")))
(test '(#f #f ("foo" "bar")) (receive (decompose-directory "foo//bar/")))

;;; ssh-config.el --- Major mode for config_config(5)   -*- lexical-binding: t; -*-

;; Copyright (C) 2015 Mario Rodas <marsam@users.noreply.github.com>

;; Author: Mario Rodas <marsam@users.noreply.github.com>
;; URL: https://github.com/emacs-pe/ssh-modes
;; Keywords: convenience
;; Version: 0.1
;; Package-Requires: ((emacs "24"))

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; A Emacs major mode for editing ssh_config(5)

;;; Code:

(defgroup ssh-config nil
  "Edit ssh-config(5) files."
  :prefix "ssh-config-"
  :group 'tools)

(defcustom ssh-config-indent-level 2
  "Indentation level for ssh-config files."
  :type 'integer
  :group 'ssh-config)

(defun ssh-config-indentation-string ()
  "Return indentation string."
  (if indent-tabs-mode "\t" (make-string (or ssh-config-indent-level tab-width) ?\ )))

(defun ssh-config-line-indented-p ()
  "Return t if current line is indented."
  (save-excursion
    (beginning-of-line)
    (or (looking-at (rx line-start symbol-start "host" symbol-end))
        (looking-at (concat (rx line-start)
                            (ssh-config-indentation-string)
                            (rx symbol-start (or (syntax word)
                                                 (syntax symbol)))))
        (looking-at "#"))))

(defun ssh-config-point-in-indentation-p ()
  "Return if the point is in the indentation of the current line."
  (save-excursion
    (let ((pos (point)))
      (back-to-indentation)
      (<= pos (point)))))

(defun ssh-config-indent-line ()
  "Indent the current line."
  (interactive)
  (if (ssh-config-line-indented-p)
      (when (ssh-config-point-in-indentation-p)
        (back-to-indentation))
    (let ((old-point (point-marker))
          (was-in-indent (ssh-config-point-in-indentation-p)))
      (beginning-of-line)
      (delete-horizontal-space)
      (unless (looking-at (rx symbol-start "host" symbol-end))
        (insert (ssh-config-indentation-string)))
      (if was-in-indent
          (back-to-indentation)
        (goto-char (marker-position old-point)))
      (set-marker old-point nil))))

(defconst ssh-config-mode-syntax-table
  (let ((table  (make-syntax-table)))
    (modify-syntax-entry ?#  "<" table)
    (modify-syntax-entry ?\n ">" table)
    table))

(defconst ssh-config-imenu-generic-expression
  `(("Hosts" ,(rx bol "host" (+ space) (group (+ (in alnum "*._-")))) 1)))

;; https://github.com/openssh/openssh-portable/blob/d028d5d3a6/readconf.c
(defconst ssh-config-font-lock-keywords
  `((,(rx (group
           symbol-start
           (or
            "addressfamily" "afstokenpassing" "batchmode" "bindaddress"
            "canonicaldomains" "canonicalizefallbacklocal"
            "canonicalizehostname" "canonicalizemaxdots"
            "canonicalizepermittedcnames" "challengeresponseauthentication"
            "checkhostip" "cipher" "ciphers" "clearallforwardings"
            "compression" "compressionlevel" "connectionattempts"
            "connecttimeout" "controlmaster" "controlpath" "controlpersist"
            "dsaauthentication" "dynamicforward" "enablesshkeysign"
            "escapechar" "exitonforwardfailure" "fallbacktorsh"
            "fingerprinthash" "forwardagent" "forwardx11"
            "forwardx11timeout" "forwardx11trusted" "gatewayports"
            "globalknownhostsfile" "globalknownhostsfile2"
            "gssapiauthentication" "gssapiauthentication"
            "gssapidelegatecredentials" "gssapidelegatecredentials"
            "hashknownhosts" "hostbasedauthentication"
            "hostbasedkeytypes" "hostkeyalgorithms" "hostkeyalias"
            "hostname" "identitiesonly" "identityfile" "identityfile2"
            "ignoreunknown" "ipqos" "kbdinteractiveauthentication"
            "kbdinteractivedevices" "keepalive" "kerberosauthentication"
            "kerberostgtpassing" "kexalgorithms" "localcommand"
            "localforward" "loglevel" "macs" "match"
            "nohostauthenticationforlocalhost" "numberofpasswordprompts"
            "passwordauthentication" "permitlocalcommand" "pkcs11provider"
            "pkcs11provider" "port" "preferredauthentications" "protocol"
            "proxycommand" "proxyusefdpass" "pubkeyauthentication"
            "rekeylimit" "remoteforward" "requesttty" "revokedhostkeys"
            "rhostsauthentication" "rhostsrsaauthentication"
            "rsaauthentication" "sendenv" "serveralivecountmax"
            "serveraliveinterval" "skeyauthentication" "smartcarddevice"
            "smartcarddevice" "streamlocalbindmask" "streamlocalbindunlink"
            "stricthostkeychecking" "tcpkeepalive" "tisauthentication"
            "tunnel" "tunneldevice" "updatehostkeys" "useprivilegedport"
            "user" "userknownhostsfile" "userknownhostsfile2" "useroaming"
            "usersh" "verifyhostkeydns" "visualhostkey" "xauthlocation")
           symbol-end)
          (+ space)
          (group (1+ any)))
     (1 font-lock-keyword-face)
     (2 font-lock-variable-name-face))
    (,(rx (group symbol-start "host" symbol-end) (+ space) (group (+ (in alnum "*._-"))))
     (1 font-lock-type-face)
     (2 font-lock-constant-face)))
  "A list of keywords allowed in a user ssh_config(5) file.")

;; FIXME: inherit from `conf-mode' or `prog-mode'?
;;;###autoload
(define-derived-mode ssh-config-mode prog-mode "ssh-config"
  "Major mode for editing ssh_config(5) files.

\\{ssh-config-mode-map}"
  :syntax-table ssh-config-mode-syntax-table
  (setq imenu-case-fold-search t
        imenu-generic-expression ssh-config-imenu-generic-expression)
  (set (make-local-variable 'comment-start) "# ")
  (set (make-local-variable 'comment-start-skip) "#+\\s-*")
  (set (make-local-variable 'font-lock-defaults)
       '(ssh-config-font-lock-keywords nil t))
  (set (make-local-variable 'indent-line-function)
       'ssh-config-indent-line)
  (imenu-add-to-menubar "Contents"))

;;;###autoload
(add-to-list 'auto-mode-alist '("ssh_config\\'" . ssh-config-mode))
;;;###autoload
(add-to-list 'auto-mode-alist '(".ssh/config\\'" . ssh-config-mode))

(provide 'ssh-config)

;;; ssh-config.el ends here

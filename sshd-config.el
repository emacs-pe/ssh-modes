;;; sshd-config.el --- Major mode for sshd_config(5)   -*- lexical-binding: t; -*-

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
;; A Emacs major mode for editing sshd_config(5)
;;
;; TODO:
;;
;; + [ ] Add indentation for "Match" block.

;;; Code:

;;;###autoload
(add-to-list 'auto-mode-alist '("sshd_config\\'" . sshd-config-mode))

(defconst sshd-config-mode-syntax-table
  (let ((table  (make-syntax-table)))
    (modify-syntax-entry ?#  "<" table)
    (modify-syntax-entry ?\n ">" table)
    table))

;; https://github.com/openssh/openssh-portable/blob/d028d5d3a69/servconf.c
(defconst sshd-config-font-lock-keywords
  `((,(rx bol (group symbol-start "match" symbol-end)
          (+ space)
          (group symbol-start
                 (or "address" "group" "host" "localaddress" "localport" "user")
                 symbol-end)
          (+ space)
          (group (+ any)))
     (1 font-lock-type-face)
     (2 font-lock-builtin-face)
     (3 font-lock-variable-name-face))
    (,(rx (group
           symbol-start
           (or
            "acceptenv" "addressfamily" "afstokenpassing"
            "allowagentforwarding" "allowgroups"
            "allowstreamlocalforwarding" "allowtcpforwarding" "allowusers"
            "authenticationmethods" "authorizedkeyscommand"
            "authorizedkeyscommanduser" "authorizedkeysfile"
            "authorizedkeysfile2" "authorizedprincipalsfile" "banner"
            "challengeresponseauthentication" "checkmail" "chrootdirectory"
            "ciphers" "clientalivecountmax" "clientaliveinterval"
            "compression" "denygroups" "denyusers" "dsaauthentication"
            "fingerprinthash" "forcecommand" "gatewayports"
            "gssapiauthentication" "gssapicleanupcredentials"
            "hostbasedacceptedkeytypes" "hostbasedauthentication"
            "hostbasedusesnamefrompacketonly" "hostcertificate" "hostdsakey"
            "hostkey" "hostkeyagent" "ignorerhosts" "ignoreuserknownhosts"
            "ipqos" "kbdinteractiveauthentication" "keepalive"
            "kerberosauthentication" "kerberosgetafstoken"
            "kerberosorlocalpasswd" "kerberostgtpassing"
            "kerberosticketcleanup" "kexalgorithms"
            "keyregenerationinterval" "listenaddress" "logingracetime"
            "loglevel" "macs" "maxauthtries" "maxsessions"
            "maxstartups" "pamauthenticationviakbdint"
            "passwordauthentication" "permitemptypasswords" "permitopen"
            "permitrootlogin" "permittty" "permittunnel"
            "permituserenvironment" "permituserrc" "pidfile" "port"
            "printlastlog" "printmotd" "protocol" "pubkeyacceptedkeytypes"
            "pubkeyauthentication" "rekeylimit" "reversemappingcheck"
            "revokedkeys" "rhostsauthentication" "rhostsrsaauthentication"
            "rsaauthentication" "serverkeybits" "skeyauthentication"
            "streamlocalbindmask" "streamlocalbindunlink" "strictmodes"
            "subsystem" "syslogfacility" "tcpkeepalive" "trustedusercakeys"
            "usedns" "uselogin" "usepam" "useprivilegeseparation"
            "verifyreversemapping" "versionaddendum" "x11displayoffset"
            "x11forwarding" "x11uselocalhost" "xauthlocation")
           symbol-end)
          (+ space)
          (group (+ any)))
     (1 font-lock-keyword-face)
     (2 font-lock-variable-name-face)))
  "A list of keywords allowed in a user sshd_config(5) file.")

;;;###autoload
(define-derived-mode sshd-config-mode prog-mode "sshd-config"
  "Major mode for editing sshd_config(5) files.

\\{sshd-config-mode-map}"
  :syntax-table sshd-config-mode-syntax-table
  (set (make-local-variable 'comment-start) "# ")
  (set (make-local-variable 'comment-start-skip) "#+\\s-*")
  (set (make-local-variable 'font-lock-defaults)
       '(sshd-config-font-lock-keywords nil t)))

(provide 'sshd-config)

;;; sshd-config.el ends here

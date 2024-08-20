/**
 * Exactag Tagmanagement Mechanism
 *
 * @copyright Exactag GmbH, Düsseldorf, Germany
 * @author Peter Viergutz
 *
 */

(function (d) {
    var P80cd9647273d4f599df44611582e873e = {
        version: "3.0.20190101",
        root: null,
        processed: false,
        doc: null,
        element: "iframe",
        testmode: false,
        uk: "cbe76e5e4ae74ecd8660fd7599cda511",
        gk: "f41c91b5e6654a1a96c928f5eda3fe60|19.10.2024 19:46:35",
        cookiemode: "set",
        cookiedomain: "axa.ch",
        isSecure: false,
        isSameSite: false,
        nfifHost: "//exactag.axa.ch",
        pixels: [],
        frameTitle: "exactag",
        pushPixel: function (pixel) {
            if (this.testmode) return;
            this.pixels.push(pixel);
        },
        deliver: function () {
            var root = d.createElement(this.element);
            root.setAttribute("title", this.frameTitle);
            root.setAttribute("aria-hidden", "true");
            d.getElementsByTagName('body')[0].appendChild(root);
            root.style.cssText = "position:absolute; z-index:-1; width:0px; height:0px; overflow: hidden; border: 0;";
            root.tabindex = "-1";
            root.srcDoc='<!DOCTYPE html><html><head></head><body></body></html>';
            root.onload = this.createDelegate(this, this.processPixels);
            this.root = this.getDocument(root);
            try {
                this.root.open();
                try {
                    this.root.write('<!DOCTYPE html><html><head></head><body></body></html>');
                }
                catch (e) {
                }
                this.root.close();
                window.setTimeout(this.createDelegate(this, this.processPixels), 250);
            } catch (e) {
                console.log("TagManager: cannot access root element");
            }

            if (this.uk != "" && this.cookiemode == "set") {
                var cookiedomain = "", hostname = this.root.location.hostname;
                if (this.cookiedomain != "" && hostname.indexOf(this.cookiedomain) > -1) {
                    cookiedomain = this.cookiedomain;
                    // clear legacy cookie (without domain)
                    this.setCookie("et_uk", null, -1);
                }

                this.setCookie("et_uk", this.uk, 180, cookiedomain, this.isSecure, this.isSameSite);
            }

            if (this.gk != "" && this.cookiemode == "set") {
                var cookiedomain = "", hostname = this.root.location.hostname;
                if (this.cookiedomain != "" && hostname.indexOf(this.cookiedomain) > -1) {
                    cookiedomain = this.cookiedomain;
                    // clear legacy cookie (without domain)
                    this.setCookie("et_gk", null, -1);
                }

                this.setCookie("et_gk", this.gk, 90, cookiedomain, this.isSecure, this.isSameSite);
            }
        },
        processPixels: function () {
            if (this.processed) return;
            this.processed = true;

            try {

                var is_chrome = window.chrome || false;
                var chrome_version = 0;
                if (is_chrome) {
                    chrome_version = parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10);
                }

            } catch (e) { }

            for (var i = 0; i < this.pixels.length; i++) {
                var pixel = this.pixels[i];
                try {

                    var leaf = this.root.createElement(this.element);
                    leaf.setAttribute("title", this.frameTitle);
                    leaf.setAttribute("aria-hidden", "true");
                    this.root.getElementsByTagName('body')[0].appendChild(leaf);

                    if (pixel.mode == "fif") {

                        doc = this.getDocument(leaf);

                        try {
                            if ((is_chrome && chrome_version >= 42) || pixel.ttl > 0) {

                                (function (doc, pixel) {
                                    window.setTimeout(function () {
                                        doc.close();
                                    }, (pixel.ttl > 0 ? pixel.ttl : 3000));
                                })(doc, pixel);

                            }
                        } catch (e) {
                            console.log("TagManager: unable to close document for pixelId " + pixel.pixelid);
                        }

                        doc.open();
                        doc.write(pixel.code);

                    } else if (pixel.mode == "nfif") {

                        leaf.setAttribute("src", this.nfifHost + "/px.aspx?id=" + pixel.id);

                    } else if (pixel.mode == "jfif") {

                        leaf.contentWindow['code'] = pixel.code;
                        leaf.setAttribute("src", 'javascript:window["code"];');
                    } else {
                        console.log("TagManager: unknown delivery mode: " + pixel.mode);
                    }

                } catch (e) {
                    console.log("TagManager: cannot deliver pixel " + pixel.code);
                }
            }
        },
        getDocument: function (obj) {
            var doc = null;
            try {
                doc = obj.contentDocument ? obj.contentDocument : (obj.contentWindow.document || obj.document);
            } catch (e) {
                console.log("TagManager: plan b in effect");
                obj.src = 'javascript:(function(){document.open();document.domain="' + document.domain + '";})()';
                doc = obj.contentDocument ? obj.contentDocument : (obj.contentWindow.document || obj.document);
            }
            return doc;
        },
        createDelegate: function (object, method) {
            return function () {
                method.apply(object, arguments);
            }
        },
        setCookie: function (name, value, days, hostname, isSecure, isSameSite) {
            var expires = "", domain = "", cookie, secure = "", sameSite = "";
            if (days) {
                var date = new Date();
                date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
                expires = "; expires=" + date.toGMTString();
            }

            if (hostname) {
                domain = "; domain=." + hostname;
            }

            if (isSecure) {
                secure = "; secure ";
            }

            if (isSameSite) {
                sameSite = "; SameSite = strict ";
            }

            var valueEscaped = window.escape(value);
            cookie = name + "=" + valueEscaped + expires + domain + "; path=/" + secure + sameSite;
            document.cookie = cookie;
        }

    };

    if (typeof console == "undefined") {
        var console = {};
        console.log = function () {
        };
    }

    

    P80cd9647273d4f599df44611582e873e.deliver();

})(document);

/*

 

 

 

 
 */
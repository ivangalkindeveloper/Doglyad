(function () {
    var SUPPORTED_LANGS = ['ru', 'en'];
    var STORAGE_KEY = 'doglyad-lang';

    function applyLang(lang) {
        SUPPORTED_LANGS.forEach(function (item) {
            var content = document.getElementById('content-' + item);
            if (content) content.classList.toggle('hidden', item !== lang);
        });
        document.querySelectorAll('.lang-btn').forEach(function (btn) {
            btn.classList.remove('active');
        });
        var activeBtn = document.querySelector('.lang-btn[onclick="switchLang(\'' + lang + '\')"]');
        if (activeBtn) activeBtn.classList.add('active');
        document.documentElement.lang = lang;
    }

    function setInsets(top, bottom) {
        var root = document.documentElement;
        root.style.setProperty('--inset-top', Math.max(0, Number(top) || 0) + 'px');
        root.style.setProperty('--inset-bottom', Math.max(0, Number(bottom) || 0) + 'px');
    }

    // Called from the language buttons inside the documents.
    window.switchLang = function (lang) {
        applyLang(lang);
        localStorage.setItem(STORAGE_KEY, lang);
    };

    // Called from the native web view whenever the sheet layout changes.
    window.doglyadSetInsets = setInsets;

    var params = new URLSearchParams(window.location.search);

    var langParam = params.get('lang');
    var isLangExplicit = SUPPORTED_LANGS.indexOf(langParam) !== -1;
    if (isLangExplicit) {
        // The host passed the locale explicitly — the document must not offer its own switch.
        document.querySelectorAll('.lang-switch').forEach(function (element) {
            element.classList.add('hidden');
        });
        applyLang(langParam);
    } else {
        var storedLang = localStorage.getItem(STORAGE_KEY);
        applyLang(SUPPORTED_LANGS.indexOf(storedLang) !== -1 ? storedLang : 'ru');
    }

    setInsets(params.get('topInset'), params.get('bottomInset'));
})();

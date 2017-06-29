function textarea_resize(select) {
    select.each(function() {
        this.setAttribute('style', 'height:' + (this.scrollHeight) + 'px;overflow-y:hidden;');
    }).on('input', function() {
        this.style.height = 'auto';
        this.style.height = (this.scrollHeight) + 'px';
    });
}

$(document).ready(function() {
    textarea_resize($("textarea.textarea-resize"));
});

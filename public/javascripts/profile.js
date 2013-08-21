$(function () {
    $('#fileupload').fileupload({
        dataType: 'json',
        done: function (e, data) {
            if (data.result && data.result.files && data.result.files[0]) {
                $('img.picture').attr('src', data.result.files[0].thumbnailUrl);
            }
        }
    });
});

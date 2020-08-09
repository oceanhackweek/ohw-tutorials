// Don't use the standard CSS import mechanism so that we can easily support directories of notebooks.
$('head').append('<link rel="stylesheet" href="/files/static/theme/rise.css" type="text/css" />');

header = `
<a href="https://oceanhackweek.github.io">
    <img src="static/theme/OHW.png" style="height: 4.5rem;" />
    OceanHackWeek
</a>
<div style="float: right;">
    <img src="static/theme/logo.jpg" style="height: 3.8rem;">
    Tutorial | OHW 2020
</div>
`;

footer = `
<a href="https://github.com/oceanhackweek/ohw20-tutorials/tree/master/01-Data-Access">https://github.com/oceanhackweek/ohw20-tutorials/tree/master/01-Data-Access</a>

<div style="float: right;"><a href="https://github.com/ocefpaf">Filipe Fernandes</a></div>
`;


$('#rise-header').html(header);
$('#rise-footer').html(footer);

index = Reveal.getIndices();
if (index.h == 0 & index.v == 0) {
    onFirstSlide();
}

Reveal.addEventListener('slidechanged', function(evt) {
  if (evt.indexh == 0 & evt.indexv == 0) {
    onFirstSlide();
  }
});


function onFirstSlide() {
  // Do the thing when first slide is being shown.
}

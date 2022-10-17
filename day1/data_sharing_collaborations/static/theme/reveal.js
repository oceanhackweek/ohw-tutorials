// Don't use the standard CSS import mechanism so that we can easily support directories of notebooks.
$('head').append('<link rel="stylesheet" href="static/theme/rise.css" type="text/css" />');

header = `
<a href="https://oceanhackweek.github.io">
    <img src="https://avatars2.githubusercontent.com/u/33128979?s=200&v=4" style="height: 4.5rem;" />
    OceanHackWeek
</a>
<div style="float: right;">
    <img src="https://secure.gravatar.com/avatar/f3257938262658419b4d2c95011b2e2e.jpg?s=512&r=g&d=mm" style="height: 3.8rem;">
    Introduction to Conda | OHW 2018
</div>
`;

footer = `
<a href="https://github.com/oceanhackweek/ohw2018_tutorials/tree/master/day1/data_sharing_collaborations">Github Source</a>

<div style="float: right;">Landung Setiawan</div>
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

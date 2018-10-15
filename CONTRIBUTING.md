# Contributing

I'm glad you're here 😃, thanks!
All friendly contributions are welcome and if unsure, feel free to [open an issue](https://github.com/tlienart/JuDoc.jl/issues/new) and we can discuss it.

You can contribute in several ways:

1. use JuDoc, report bugs or suggest features by [filing an issue](https://github.com/tlienart/JuDoc.jl/issues/new),
1. suggest improvement to the code,
1. suggest themes or link to your site that uses JuDoc.
1. [other ways to contribute](#other-ways-to-contribute)

The first one is straightforward, please just quickly check that your issue is aligned with the [judoc spirit](#judoc-spirit).

For the second one, feel free to suggest anything, though I will prioritise help in the following areas:

1. **bug fixes**: any fixes to problematic behaviour.
1. **error handling**: at the moment the error handling is basic to say the least, anything to help errors being better/more sensibly handled would be great.
1. **documentation**: at the moment there's little documentation, the doc doesn't need to be crazy large as most of it should be pretty straightforward but clear examples for the key features would be useful.
1. **diminish 3d party dependencies**: at the moment, the packages assumes that you will work with `browser-sync` and `css-html-js-minify`; that's not too much of an issue as these two tools are super easy to install and are very fast, however if there's a nice way to use 100% Julia, it'd be nice. In particular,  for `browser-sync`, that would help removing the hacky `PID` management and I think some of the web stuff from Julia could do the job.  


## JuDoc spirit

The key objectives of JuDoc were to have something that:

1. can be used by people who have little experience with webdev,
1. is in Julia, is fast™ for local editing, and can be easily extended,
1. generates all the HTML/CSS locally with the exception of maths and code rendering (via KaTeX and highlightjs respectively),
1. generates pages that are *lightweight* and *load fast™*,
1. generates pages that are easy to understand for non-web-experts.

In particular, themes should refrain from using too much additional JavaScript or intricate CSS if possible.

Further to the above requirements, I'm generally against data tracking and add serving so even though it's perfectly possible to add all that to your page around JuDoc, it's not the kind of stuff I'd encourage.

## Other ways to contribute

There may be many things to fix / improve in the code, for instance it might be possible to rewrite the parser so that it handles more complex syntax and works better.
If you have ideas about such improvements, I'm happy to discuss them with you though, as said earlier, I will prioritise things which make the experience of users better.

There may also be ways to improve the structure of the HTML document that gets generated.
My knowledge of webdev is too limited to see how much potential there is in that area but help is most welcome in that area too.

html
  head
    title
      = locals[:title]
    / jQuery
    script src="/assets/javascript/jquery-3.2.1.min.js"
    / Bootstrap
    link rel="stylesheet" href="/assets/stylesheet/bootstrap.min.css"
    link rel="stylesheet" href="/assets/stylesheet/bootstrap-theme.min.css"
    script src="/assets/javascript/bootstrap.min.js"
    / Custom
    link rel="stylesheet" href="/assets/stylesheet/base.css"
    script src="/assets/javascript/base.js"

    / link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"
    / link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous"
    / script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"
  body
    nav
      / a href="/pages/new" New page
    div#content.container
      == content

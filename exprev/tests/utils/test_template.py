from exprev.utils.template import render_template

def test_render_one_macro():
    s = render_template("hello ${crunch_date}", {'crunch_date': 'world'}) 
    assert s == 'hello world'

def test_render_one_macro_two_places():
    s = render_template("hello ${crunch_date}, again ${crunch_date}", {'crunch_date': 'world'}) 
    assert s == 'hello world, again world'
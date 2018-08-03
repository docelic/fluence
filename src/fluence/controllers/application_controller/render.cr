class ApplicationController
  # This code belongs to the Amber Project: https://github.com/Amber-Crystal/amber/blob/master/src/amber/controller/render.cr
  #
  # The MIT License (MIT)
  #
  # Copyright (c) 2017 Elias Perez
  #
  # Permission is hereby granted, free of charge, to any person obtaining a copy
  # of this software and associated documentation files (the "Software"), to deal
  # in the Software without restriction, including without limitation the rights
  # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  # copies of the Software, and to permit persons to whom the Software is
  # furnished to do so, subject to the following conditions:
  #
  # The above copyright notice and this permission notice shall be included in
  # all copies or substantial portions of the Software.
  #
  # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  # THE SOFTWARE.
  module Render
    macro render_template(filename, path = "src/fluence/views")
      {% if filename.id.split("/").size > 2 %}
        Kilt.render("{{filename.id}}")
      {% else %}
        Kilt.render("#{{{path}}}/{{filename.id}}")
      {% end %}
    end

    macro render(filename, layout = true, path = "src/fluence/views", folder = __FILE__)
      # NOTE: content is basically yield rails layouts.
      {% if filename.id.split("/").size > 1 %}
        content = render_template("#{{{filename}}}", {{path}})
      {% else %}
        {% if folder.id.ends_with?(".ecr") %}
          content = render_template("#{{{folder.split("/")[-2]}}}/#{{{filename}}}", {{path}})
        {% else %}
          content = render_template("#{{{folder.split("/").last.gsub(/\_controller\.cr|\.cr/, "")}}}/#{{{filename}}}", {{path}})
        {% end %}
      {% end %}

      {% if layout && !filename.id.split("/").last.starts_with?("_") %}
        content = render_template("layouts/#{{{layout.class_name == "StringLiteral" ? layout : LAYOUT}}}", {{path}})
      {% end %}
      content
    end
  end
end

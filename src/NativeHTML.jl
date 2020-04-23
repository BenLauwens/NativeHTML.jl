module NativeHTML

import Base.div

struct HTML
    data::Array{UInt8,1}
end

Base.showable(::MIME"text/html", _::HTML) = true

Base.showable(::MIME{Symbol("juliavscode/html")}, _::HTML) = true

function Base.show(io::IO, html::HTML)
    write(io, String(copy(html.data)))
end

function Base.show(io::IO, ::MIME"text/plain", html::HTML)
    (isdefined(Main, :IJulia) && Main.IJulia.inited ||
     isdefined(Main, :Juno) && Main.Juno.isactive()) && return
    filename = "NativeHTML.html"
    open(filename, "w") do io
        write(io, html.data)
    end
    if Sys.isapple()
        run(`open $(filename)`)
    elseif Sys.iswindows()
        cmd = get(ENV, "COMSPEC", "cmd")
        run(`$(ENV["COMSPEC"]) /c start $(filename)`)
    elseif Sys.isunix()
        run(`xdg-open $(filename)`)
    end
    return filename
end

function Base.show(io::IO, ::MIME"text/html", html::HTML)
    write(io, html.data)
end

function Base.show(io::IO, ::MIME{Symbol("juliavscode/html")}, html::HTML)
    write(io, html.data)
end

function Base.write(io::IO, html::HTML)
    write(io, html.data)
end

function html(f::Function)
    io = IOBuffer()
    println(io, "<!DOCTYPE html>")
    println(io, "<html>")
    task_local_storage(:htmlio, io)
    task_local_storage(:level, 1)
    f()
    println(io, "</html>")
    HTML(take!(io))
end

export html

function fragment(f::Function; level::Int = 0)
    io = IOBuffer()
    task_local_storage(:htmlio, io)
    task_local_storage(:level, level)
    f()
    HTML(take!(io))
end

export fragment

const PRIMITIVES = Dict(
    # metadata
    :head => true,
    :title => true,
    :base => false,
    :link => false,
    :meta => false,
    :style => true,
    # sections
    :body => true,
    :article => true,
    :section => true,
    :nav => true,
    :aside => true,
    :h1 => true,
    :h2 => true,
    :h3 => true,
    :h4 => true,
    :h5 => true,
    :h6 => true,
    :hgroup => true,
    :header => true,
    :footer => true,
    :address => true,
    # grouping
    :p => true,
    :hr => false,
    :pre => true,
    :blockquote => true,
    :ol => true,
    :ul => true,
    :menu => true,
    :li => true,
    :dl => true,
    :dt => true,
    :dd => true,
    :figure => true,
    :figcaption => true,
    :main => true,
    :div => true,
    # text-level
    :a => true,
    :em => true,
    :strong => true,
    :small => true,
    :s => true,
    :cite => true,
    :q => true,
    :dfn => true,
    :abbr => true,
    :ruby => true,
    :rt => true,
    :rp => true,
    :data => true,
    :time => true,
    :code => true,
    :var => true,
    :samp => true,
    :kbd => true,
    :sub => true,
    :sup => true,
    :i => true,
    :b => true,
    :u => true,
    :mark => true,
    :bdi => true,
    :bdo => true,
    :span => true,
    :br => false,
    :wbr => false,
    # edits
    :ins => true,
    :del => true,
    # embedded
    :picture => true,
    :source => false,
    :img => false,
    :iframe => true,
    :embed => false,
    :object => true,
    :param => false,
    :video => true,
    :audio => true,
    :track => false,
    :map => true,
    :area => false,
    # tables
    :table => true,
    :caption => true,
    :colgroup => true,
    :col => false,
    :tbody => true,
    :thead => true,
    :tfoot => true,
    :tr => true,
    :td => true,
    :th => true,
    # forms
    :form => true,
    :label => true,
    :input => false,
    :button => true,
    :select => true,
    :datalist => true,
    :optgroup => true,
    :option => true,
    :textarea => true,
    :output => true,
    :progress => true,
    :meter => true,
    :fieldset => true,
    :legend => true,
    # interactive
    :details => true,
    :summary => true,
    # scripting
    :script => true,
    :noscript => true,
    :template => true,
    :slot => true,
    :canvas => true,
)

for (primitive, notvoid) in PRIMITIVES
    eval(quote
        function $primitive(txt::String = ""; kwargs...)
            let io = task_local_storage(:htmlio), level = task_local_storage(:level)
                print(io, " " ^ level, "<", $primitive)
                for (arg, val) in kwargs
                    print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
                end
                if txt === "" 
                    $notvoid ? println(io, "/>") : println(io, ">")
                else
                    println(io, ">", txt, "</", $primitive, ">")
                end
            end
        end
    end)
end

for primitive in keys(PRIMITIVES)
    eval(quote
        export $primitive
    end)
end

for primitive in keys(filter(d->last(d), PRIMITIVES))
    eval(quote
        function $primitive(f::Function; kwargs...)
            let io = task_local_storage(:htmlio), level = task_local_storage(:level)
                print(io, " " ^ level, "<", $primitive)
                for (arg, val) in kwargs
                    print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
                end
                println(io, ">")
                task_local_storage(:level, level + 1)
                f()
                task_local_storage(:level, level)
                println(io, " " ^ level, "</", $primitive, ">")
            end
        end
    end)
end

function text(txt::String)
    let io = task_local_storage(:htmlio), level = task_local_storage(:level)
        println(io, " " ^ level, txt)
    end
end

export text

function cdata(txt::String)
    let io = task_local_storage(:htmlio), level = task_local_storage(:level)
        println(io, " " ^ level, "<![CDATA[", txt, "]]>")
    end
end

export cdata  

function replacenotallowed(key::Symbol)
    str = replace(String(key), '_' => '-')
    str[begin] === '-' && return str[begin+1:end]
    str
end

end

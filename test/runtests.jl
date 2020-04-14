using NativeHTML

frag = fragment() do
    div() do
        span("Hello", style="color:red;")
        text(", ")
        b("World!")
    end
end

display(frag)

page = html() do
    head() do
        title("Hello, World!")
    end
    body() do
        div() do
            span("Hello", style="color:red;")
            text(", ")
            b("World!")
        end
    end
end

display(page)
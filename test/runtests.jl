using NativeHTML

const email = "ben.lauwens@rma.ac.be"

page = html() do
    head() do
        meta(charset="utf-8")
        meta(name="viewport", content="width=device-width, initial-scale=1")
        title("Test")
    end
    body(style="background-color: white;") do
        header(id="header") do
            div() do
                a(href="/", rel="noopener") do
                    img(src="/static/logo-rma.jpg")
                    span("Management Software")
                end
            end
            div() do
                a(class="icon") do
                    i(class="fas fa-user")
                end
                a(class="icon") do
                    i(class="fas fa-toolbox")
                end
            end
            div() do
                if email !== nothing
                    a(email, href="/users/profile")
                    a(class="icon", href="/logout") do
                        i(class="fas fa-sign-out-alt")
                    end
                else
                    a(class="icon", href="/login") do
                        i(class="fas fa-sign-in-alt")
                    end
                end
            end
        end
    end
end

frag = fragment() do
    div() do
        span("Test", style="color: red;")
        p() do
            text("Dit is een Test.")
            b("In vet!")
            text("Dit is nog een Test.")
        end
        div() do
            span("Test", style="color: red;")
            p() do
                text("Dit is een Test.")
                b("In vet!")
                text("Dit is nog een Test.")
            end
        end
    end
end

display(frag)
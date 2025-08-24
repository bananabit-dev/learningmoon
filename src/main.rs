use dioxus::prelude::*;
mod ui;
use ui::views::auth::login::Login;
use ui::views::auth::register::Register;

#[derive(Debug, Clone, Routable, PartialEq)]
#[rustfmt::skip]
enum Route {
    #[layout(Navbar)]
    #[route("/")]
    Home {},
    #[route("/login")]
    Login {},
    #[route("/register")]
    Register {},
}

const FAVICON: Asset = asset!("/assets/favicon.ico");
const MAIN_CSS: Asset = asset!("/assets/main.css");
const TAILWIND_CSS: Asset = asset!("/assets/tailwind.css");

fn main() {
    #[cfg(feature = "web")]
    {
        // Client-side WASM launch
        dioxus::launch(App);
    }

    #[cfg(feature = "api")]
    {
        use axum::Router;
        use dioxus::fullstack::ServeConfig;
        use tower_http::services::ServeDir;
        // Server-side Axum launch
        tokio::runtime::Runtime::new().unwrap().block_on(async {
            // Build Axum router
            let app = Router::new()
                // Serve static assets (WASM, JS, CSS, favicon, etc.)
                .nest_service("/assets", ServeDir::new("public/assets"))
                .nest_service("/", ServeDir::new("public"))
                // Serve the Dioxus SPA (index.html + hydration)
                .serve_dioxus_application(ServeConfig::builder().build().unwrap(), App);

            let addr = dioxus::cli_config::fullstack_address_or_localhost();
            println!("🚀 Server running at http://{}", addr);

            axum::serve(tokio::net::TcpListener::bind(addr).await.unwrap(), app)
                .await
                .unwrap();
        });
    }
}

#[component]
fn App() -> Element {
    rsx! {
        document::Link { rel: "icon", href: FAVICON }
        document::Link { rel: "stylesheet", href: MAIN_CSS } document::Link { rel: "stylesheet", href: TAILWIND_CSS }
        Router::<Route> {}
    }
}

/// Home page
#[component]
fn Home() -> Element {
    rsx! {
        p { "Welcome to learningmoon !" }
    }
}

/// Shared navbar component.
#[component]
fn Navbar() -> Element {
    rsx! {
        div {
            id: "navbar",
            Link {
                to: Route::Home {},
                "Home"
            }
            Link {
                to: Route::Login {},
                "Login"
            }
            Link {
                to: Route::Register {},
                "Register"
            }
        }

        Outlet::<Route> {}
    }
}

use dioxus::prelude::*;
use ui::App;

fn main() {
        // Client-side WASM launch
        server_fn::client::set_server_url("https://learningmoon.app");
        dioxus::launch(App);
}

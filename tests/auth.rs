use dioxus::prelude::*;
use dioxus_ssr::render;

use crate::components::login::Login;
use crate::components::register::Register;

#[test]
fn login_form_renders() {
    let mut vdom = VirtualDom::new(Login);
    let _ vdom.rebuild();

    let html = render(&vdom);

    assert!(html.contains("Login"), "Login title missing");
    assert!(html.contains("id=\"email\""), "Email input missing");
    assert!(html.contains("id=\"password\""), "Password input missing");
    assert!(html.contains("id=\"submit\""), "Submit button missing");

}
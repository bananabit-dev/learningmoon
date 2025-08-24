use dioxus::prelude::*;

#[component]
pub fn Login() -> Element {
    rsx! {
        div {
            class: "flex flex-col items-center justify-center w-11/12 max-w-md mx-auto p-6 space-y-4",

            // Email input
            div {
                class: "w-full flex flex-col space-y-1",
                label { class: "text-sm font-medium", "Email:" }
                input {
                    type: "email",
                    placeholder: "Enter your email",
                    class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                }
            }

            // Password input
            div {
                class: "w-full flex flex-col space-y-1",
                label { class: "text-sm font-medium", "Password:" }
                input {
                    type: "password",
                    placeholder: "Enter your password",
                    class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                }
            }

            // Login button
            button {
                class: "w-full py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition",
                "Login"
            }
        }
    }
}


#[cfg(test)]
mod tests {
    use super::*;
    use dioxus::core::NoOpMutations;

    #[test]
    fn login_component_renders() {
        let mut dom = VirtualDom::new(Login);

        // Rebuild the component tree with a no-op mutations sink
        dom.rebuild(&mut NoOpMutations);

        // If we got here without panic, the component rendered successfully
        // (no need to inspect VNode internals in 0.7)
    }
}
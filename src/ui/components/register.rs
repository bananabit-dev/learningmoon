use dioxus::prelude::*;

#[component]
pub fn Register() -> Element {
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
                    class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                }
            }

            // Password input
            div {
                class: "w-full flex flex-col space-y-1",
                label { class: "text-sm font-medium", "Password:" }
                input {
                    type: "password",
                    placeholder: "Enter your password",
                    class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                }
            }

            // Register button
            button {
                class: "w-full py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition",
                "Register"
            }
        }
    }
}
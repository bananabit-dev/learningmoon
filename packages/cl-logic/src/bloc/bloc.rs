use async_trait::async_trait;
use futures::stream::Stream;
use std::pin::Pin;
use tokio::sync::broadcast;
use tokio::sync::RwLock;
use std::sync::Arc;

/// Base trait for all BLoCs
#[async_trait]
pub trait Bloc: Send + Sync {
    type Event: Send + Sync + Clone;
    type State: Send + Sync + Clone;
    
    async fn handle_event(&self, event: Self::Event);
    fn get_state(&self) -> Self::State;
    fn state_stream(&self) -> Pin<Box<dyn Stream<Item = Self::State> + Send>>;
}

/// Base BLoC implementation with state management
pub struct BlocBase<S: Clone + Send + Sync> {
    state: Arc<RwLock<S>>,
    state_sender: broadcast::Sender<S>,
}

impl<S: Clone + Send + Sync + 'static> BlocBase<S> {
    pub fn new(initial_state: S) -> Self {
        let (state_sender, _) = broadcast::channel(100);
        Self {
            state: Arc::new(RwLock::new(initial_state)),
            state_sender,
        }
    }
    
    pub async fn emit_state(&self, new_state: S) {
        let mut state = self.state.write().await;
        *state = new_state.clone();
        let _ = self.state_sender.send(new_state);
    }
    
    pub async fn get_current_state(&self) -> S {
        self.state.read().await.clone()
    }
    
    pub fn subscribe(&self) -> broadcast::Receiver<S> {
        self.state_sender.subscribe()
    }
}
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Turn {
    v,
    m,
}

impl Turn {
    pub fn flip(&self) -> Self {
        match self {
            Turn::v => Turn::m,
            Turn::m => Turn::v,
        }
    }
}

pub fn generate_dragon_word(iterations: usize) -> Vec<Turn> {
    let mut word: Vec<Turn> = Vec::new();
    for _ in 0..iterations {
        let mut inverted_flipped: Vec<Turn> = word
            .iter()
            .rev()
            .map(|turn| turn.flip())
            .collect();
        word.push(Turn::v);
        word.append(&mut inverted_flipped);
    }
    word
}


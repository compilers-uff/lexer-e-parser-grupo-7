session=lexer_parser

tmux new-session -d -s $session
tmux send-keys -t $session:0 "mvn package" C-m

tmux new-window -t $session:1
tmux send-keys -t $session:1 "nvim -O ./src/main/jflex/chocopy/pa1/ChocoPy.jflex ./src/main/cup/chocopy/pa1/ChocoPy.cup" C-m

tmux attach-session -t $session:1

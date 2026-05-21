git clone https://github.com/Lunitasz/dotfiles.git 

cd dotfiles

chmod +x install.sh

./install.sh

-nvchad 

-git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
~/.zsh/zsh-syntax-highlighting
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 

-git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions 
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh 


sudo apt install bat
sudo ln -s /usr/bin/batcat /usr/local/bin/bat 

FROM ubuntu:20.04
RUN apt-get update
RUN apt-get -y install shellcheck git curl unzip python3-pip ruby-full
RUN git clone https://github.com/tfutils/tfenv.git ~/.tfenv
RUN echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
RUN PATH="$HOME/.tfenv/bin:$PATH" tfenv install 1.0.3
RUN pip3 install pre-commit

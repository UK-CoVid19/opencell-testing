FROM ruby:2.7
RUN apt-get update -qq && apt-get install -y postgresql-client curl
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash
RUN apt-get install nodejs
RUN mkdir /opencell
WORKDIR /opencell
COPY Gemfile /opencell/Gemfile
COPY Gemfile.lock /opencell/Gemfile.lock
RUN bundle install --jobs=4
RUN npm install
COPY . /opencell

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
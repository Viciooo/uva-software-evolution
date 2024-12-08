### How to run clone detection?
Launch rascal shell
`import Main`;
`main(<your project location>);`
Check out logs and *result.txt* file to see run details.

### How to run visualization?

#### Using Docker:
`docker pull viciooo/se-series2-clone-vis:latest`
`docker run -p 3000:80 viciooo/se-series2-clone-vis:latest`

#### Locally:
`cd /clone-vis`

You will need node v16 to run the react project:

`nvm install 16 && nvm use 16 && npm install -g npm@latest && npm install && npm start`

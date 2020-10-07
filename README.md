
1. [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) is an intentionally insecure web application for training and education purposes.
2. [OWASP ZAP](https://www.zaproxy.org/) is web app security scanner. It gathers traffic using a proxy, further explore, passive and active scan web applications for potential vulnerabilities.
3. [Cypress](https://www.cypress.io) is an UI/E2E testing framework for web applications. You know Selenium? Cypress is more awesome in every aspect. [See why in an article by me](https://blog.codecentric.de/en/2020/10/cypress-ui-end2end-testing/)

## The Why and How
### Combining two great tools for a higher goal

These tools can be combined in an interesting way. **Cypress** can proxy all of its traffic generated during test execution through **OWASP ZAP**. ZAP will roughly learn which sites the web app under test has. It gathers security alerts found in the traffic. Afterwards ZAP can run active scans against the application in addition. These try some active attacks against the site, such as SQL injections or Cross-Site-Scripting attempts. OWASP ZAP afterwards provides reports including all found vulnerabilities.

### OWASP Juice Shop as demo application

The famous JS has a fair amount of serious vulnerabilities. Therefor it's perfect for demonstrating what kind of vulnerabilities and smells can be discovered with automated click tests and active scanning.

## Running it

### Locally against remote Juice Shop

Juice Shop is up already on: https://juice-shop.herokuapp.com

Start OWASP ZAP in headless mode using Docker, as we just need its HTTP API, on `http://localhost:8080`:

```bash
docker run -u zap -p 8080:8080 jverhoelen/owasp-zap-with-entrypoint
# this image is a variant of https://github.com/zaproxy/zaproxy/blob/develop/docker/Dockerfile-bare
# it has been built from file https://github.com/jverhoelen/zaproxy/blob/develop/docker/Dockerfile-bare-entrypoint
# it just runs ZAP as Docker entrypoint using its bash script wrapper zap.sh with some default arguments so it binds to 0.0.0.0:8080 as daemon without API key
```

Configure ZAP as proxy for Cypress and run tests:

```bash
nvm use
npm i

export HTTP_PROXY=http://localhost:8080
export HTTPS_PROXY=http://localhost:8080

npm run remote:cypress
npm run remote:zap-active-scan
# or "npm run remote:all" for both after another
```

### Locally against dockerized Juice Shop

Unfortunately this is hard to achieve since Cypress is limited to proxy traffic **not from localhost**. Juice Shop is nicely dockerized an can be started easily (`docker run -p 3000:3000 bkimminich/juice-shop`). However, it is then available on `localhost:3000`. Cypress test traffic will therefor not be proxied through ZAP. Also the approach of adding a line such as `127.0.0.1     juiceshop` to `/etc/hosts` does not work as dockerized ZAP is not able to access the Juice Shop via a host entry from within Docker.

This is also a problem in CI environments when trying to run Juice Shop as a "service" (Gitlab CI and Github actions offer this feature). Services in most CI systems are exposed via `localhost` or a host entry which is then not proxyable by Cypress or not accessible via host entry by ZAP. That's the reason for targeting a hosted variant on the internet.

If you've got a running solution to run all involed applications locally or in CI, feel free to contribute or hit me up :-)
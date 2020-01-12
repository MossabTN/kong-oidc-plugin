FROM kong:1.3

#COPY ./kong.conf /etc/kong/kong.conf
COPY ./ /usr/local/kong-oidc/
WORKDIR /usr/local/kong-oidc/
RUN luarocks make *.rockspec


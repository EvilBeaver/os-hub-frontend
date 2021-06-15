FROM evilbeaver/onescript:1.4.0

COPY src /app
WORKDIR /app
RUN opm install -l

FROM evilbeaver/oscript-web:0.9.0

ENV ASPNETCORE_ENVIRONMENT=Production
COPY --from=0 /app .

WORKDIR /app
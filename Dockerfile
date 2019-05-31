FROM evilbeaver/onescript:1.0.21

COPY src /app
WORKDIR /app
RUN opm install -l

FROM evilbeaver/oscript-web:0.3.2
ENV ASPNETCORE_ENVIRONMENT=Production
COPY --from=0 /app .
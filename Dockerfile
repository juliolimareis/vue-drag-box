FROM node:18.17.1 as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm i -g pnpm@7.19.0
RUN pnpm i
COPY ./ .
RUN pnpm build

FROM nginx as production-stage
RUN mkdir /app
COPY --from=build-stage /app/dist /app
COPY nginx.conf /etc/nginx/nginx.conf

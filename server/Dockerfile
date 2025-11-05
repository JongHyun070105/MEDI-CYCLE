# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# 한글 폰트 및 Puppeteer 의존성 설치 (Alpine Linux)
RUN apk add --no-cache \
    font-noto-cjk \
    font-noto-cjk-extra \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    && rm -rf /var/cache/apk/*

COPY package*.json ./

RUN npm ci --production

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/src/database/schema.sql ./
# 폰트 파일 복사 (프로젝트에 포함된 폰트가 있으면 복사)
COPY fonts ./fonts

EXPOSE 3000

CMD ["node", "dist/index.js"]


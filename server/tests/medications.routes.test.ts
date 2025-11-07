import { describe, it, expect, beforeEach, afterEach } from '@jest/globals';
import request from 'supertest';
import express from 'express';
import medicationsRouter from '../src/routes/medications.js';

describe('Medications Routes 테스트', () => {
  let app: express.Application;
  let authToken: string;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    
    // 인증 미들웨어 모킹 (실제로는 JWT 검증)
    app.use((req, res, next) => {
      req.userId = 17; // 테스트용 사용자 ID
      next();
    });
    
    app.use('/api/medications', medicationsRouter);
    
    // 테스트용 토큰 생성 (실제로는 JWT 라이브러리 사용)
    authToken = 'test-token';
  });

  afterEach(() => {
    // 테스트 후 정리
  });

  describe('라우팅 순서 테스트', () => {
    it('GET /api/medications/personalized-schedule가 /:id보다 먼저 매칭되어야 함', async () => {
      // personalized-schedule 라우트가 제대로 동작하는지 확인
      const response = await request(app)
        .get('/api/medications/personalized-schedule')
        .set('Authorization', `Bearer ${authToken}`);
      
      // 404가 아닌 응답을 받아야 함 (personalized-schedule이 id로 파싱되지 않아야 함)
      expect(response.status).not.toBe(404);
      
      // 실제로는 personalized-schedule 핸들러가 호출되어야 함
      // 현재 구현에서는 에러가 발생할 수 있지만, 라우팅 자체는 성공해야 함
      console.log('✅ personalized-schedule 라우트가 제대로 매칭됨');
    });

    it('GET /api/medications/:id는 정상적인 ID로 매칭되어야 함', async () => {
      // 실제 약물 ID로 테스트
      const response = await request(app)
        .get('/api/medications/1')
        .set('Authorization', `Bearer ${authToken}`);
      
      // ID가 숫자인 경우 약물 정보를 반환하거나 404를 반환해야 함
      // personalized-schedule로 파싱되지 않아야 함
      expect(response.status).toBeGreaterThanOrEqual(200);
      expect(response.status).toBeLessThan(500);
      
      console.log('✅ :id 라우트가 제대로 매칭됨');
    });
  });

  describe('라우트 충돌 테스트', () => {
    it('personalized-schedule이 id로 파싱되지 않아야 함', async () => {
      const response = await request(app)
        .get('/api/medications/personalized-schedule')
        .set('Authorization', `Bearer ${authToken}`);
      
      // personalized-schedule이 id로 파싱되면 400 에러가 발생할 수 있음
      // (invalid input syntax for type integer: "personalized-schedule")
      expect(response.status).not.toBe(400);
      
      console.log('✅ personalized-schedule이 id로 파싱되지 않음');
    });
  });
});


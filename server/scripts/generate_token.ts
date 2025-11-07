import jwt from 'jsonwebtoken';

const JWT_SECRET = 'medicycle_jwt_secret_key_change_in_production';
const userId = 18;

const token = jwt.sign({ userId }, JWT_SECRET, { expiresIn: '1h' });
console.log('🔑 생성된 토큰:');
console.log(token);


import os
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()


class Settings(BaseModel):
    mysql_host: str = os.getenv("MYSQL_HOST", "127.0.0.1")
    mysql_port: int = int(os.getenv("MYSQL_PORT", "3307"))
    mysql_user: str = os.getenv("MYSQL_USER", "root")
    mysql_password: str = os.getenv("MYSQL_PASSWORD",)
    mysql_db: str = os.getenv("MYSQL_DB", "medicycle")

    jwt_secret: str = os.getenv("JWT_SECRET")
    jwt_algorithm: str = os.getenv("JWT_ALG", "HS256")
    jwt_access_token_expires_minutes: int = int(os.getenv("JWT_EXPIRES_MIN", "60"))

    gemini_api_key: str | None = os.getenv("GEMINI_API_KEY")

    # MFDS e약은요
    mfds_service_key: str | None = os.getenv("MFDS_SERVICE_KEY")


settings = Settings()

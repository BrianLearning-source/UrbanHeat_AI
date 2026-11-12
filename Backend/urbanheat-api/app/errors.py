"""Semua error dikembalikan dengan format yang SAMA:
{"error": {"code": "...", "message": "..."}}
Jadi Flutter cukup menulis satu cara membaca error."""
from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse


class ApiError(Exception):
    def __init__(self, status_code: int, code: str, message: str):
        self.status_code = status_code
        self.code = code
        self.message = message


def _body(code: str, message: str) -> dict:
    return {"error": {"code": code, "message": message}}


def register_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(ApiError)
    async def api_error_handler(_: Request, exc: ApiError):
        return JSONResponse(status_code=exc.status_code, content=_body(exc.code, exc.message))

    @app.exception_handler(RequestValidationError)
    async def validation_handler(_: Request, exc: RequestValidationError):
        first = exc.errors()[0]
        field = ".".join(str(p) for p in first["loc"] if p != "body")
        return JSONResponse(
            status_code=422,
            content=_body("INVALID_INPUT", f"Input tidak valid pada '{field}': {first['msg']}"),
        )

    @app.exception_handler(Exception)
    async def unexpected_handler(_: Request, exc: Exception):
        # Jangan bocorkan detail internal ke pengguna; cukup catat di log.
        print(f"Unexpected error: {exc!r}")
        return JSONResponse(status_code=500, content=_body("INTERNAL_ERROR", "Terjadi kesalahan pada server."))

# gRPC Service Implementation Template -- C++/CMake

> Universal rules: `.claude/templates/tdd/green-rest.md`

## Tech-Specific Rules

- Use constructor injection — accept usecase references via constructor
- Services inherit from generated `::grpc::Service` base

## Reference (read before generating)

- Service example: `backend/adapters/grpc/src/controller/task/task_service.cpp`
- Service header: `backend/adapters/grpc/include/grpc/controller/task/task_service.h`
- Request DTO: `backend/adapters/grpc/src/dto/task/create_task_request_dto.h`
- Response DTO: `backend/adapters/grpc/src/dto/task/create_task_response_dto.h`

## Key Paths

- Services: `backend/adapters/grpc/src/controller/`
- Headers: `backend/adapters/grpc/include/grpc/controller/`
- DTOs: `backend/adapters/grpc/src/dto/`
- Tests: `backend/adapters/grpc/tests/controller/`

# gRPC Service Test Template -- C++/CMake

> Universal rules: `.claude/templates/tdd/red-rest.md`

## Tech-Specific Rules

- Use Google Test fixture with GMock
- Mock use-case classes with GMock `MOCK_METHOD`
- Create exactly ONE `TEST_F` method, add `DISABLED_` prefix
- Setup: `EXPECT_CALL(mock, method(_)).WillOnce(Return(value))`
- Execute: call gRPC service method with protobuf request
- Verify: compare protobuf response fields against expected values

## Expected Response

Define expected protobuf field values as constants in the test file.

## Reference (read before generating)

- Test example: `backend/adapters/grpc/tests/controller/task/task_service_test.cpp`
- Service example: `backend/adapters/grpc/src/controller/task/task_service.cpp`
- Proto files: `backend/adapters/grpc/proto/`
- Request DTO: `backend/adapters/grpc/src/dto/task/create_task_request_dto.h`

## Key Paths

- Tests: `backend/adapters/grpc/tests/controller/`
- Production: `backend/adapters/grpc/src/controller/`
- DTOs: `backend/adapters/grpc/src/dto/`
- Proto definitions: `backend/adapters/grpc/proto/`

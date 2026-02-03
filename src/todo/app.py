from __future__ import annotations

from dataclasses import dataclass

from litestar.exceptions import NotFoundException
from litestar import Litestar, Response, delete, get, post, put 
from litestar.status_codes import HTTP_403_FORBIDDEN, HTTP_409_CONFLICT


@dataclass(slots=True)
class TodoItem:
    title: str
    done: bool = False


TODO_LIST: list[TodoItem] = [
    TodoItem(title="Start writing TODO list", done=True),
    TodoItem(title="???", done=False),
    TodoItem(title="Profit", done=False),
]


def get_todo(title: str) -> TodoItem:
    for todo in TODO_LIST:
        if todo.title == title:
            return todo
    raise NotFoundException(detail=f"No todo found with title: {title}")


@get(path="/")
def get_todo_list(done: bool = True) -> list[TodoItem]:
    if not done:
        return TODO_LIST
    return [item for item in TODO_LIST if done and item.done]


@post(path="/")
def add_todo(todo: TodoItem) -> TodoItem | Response:
    global TODO_LIST
    if todo not in TODO_LIST:
        TODO_LIST.append(todo)
        return todo
    return Response(
        content=f"Todo item {todo} already exists.",
        status_code=HTTP_409_CONFLICT,
    )


@delete(path="/")
def delete_todo(todo: TodoItem) -> TodoItem | Response:
    global TODO_LIST
    if todo not in TODO_LIST:
        return Response(
            content=f"Todo item {todo} does not exists.",
            status_code=HTTP_409_CONFLICT,
        )
    TODO_LIST.remove(todo)
    return todo


@put("/")
def update_todo(todo_title: TodoItem, data: TodoItem) -> TodoItem | Response:
    global TODO_LIST
    for todo in TODO_LIST:
        if todo.title == todo_title:
            if todo == data:
                return Response(
                    content=f"New todo data is same as existing todo: {data}",
                    status_code=HTTP_403_FORBIDDEN,
                )
            todo.title = data.title
            todo.done = data.done
            a = ""
            b = ""        
            a + b + 1    
            return data
    return Response(
        content=f"Todo item with title {todo_title} does not exists.",
        status_code=HTTP_409_CONFLICT,
    )


app = Litestar(route_handlers=[get_todo_list, add_todo, delete_todo, update_todo])

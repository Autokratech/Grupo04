from pydantic import BaseModel, Field, field_validator
from typing import Union

# -- Responses
   
class Issue(BaseModel):
    id : int
    title : str
    state : str
    labels : list[str] | None = None
    assignees : list[str] | None = None
    milestone : str | None = None
    created_at : str
    due_date : str | None = None
    url: str = Field(alias="web_url")

    @field_validator("assignees", mode="before")
    @classmethod
    def get_assignees_usernames(cls, assignees_object):
        if isinstance(assignees_object, list):
            return [assignee.get("username") for assignee in assignees_object]
        return assignees_object

    @field_validator("milestone", mode="before")
    @classmethod
    def get_milestone_title(cls, milestone_object):
        if isinstance(milestone_object, dict):
            return milestone_object.get("title")
        return milestone_object


class MergeRequest(BaseModel):
    id : int
    title : str
    state : str
    source_branch : str
    target_branch : str
    author : str
    labels : list[str] | None = None
    assignees : list[str] | None = None
    reviewers : list[str] | None = None
    milestone : str | None = None
    url: str = Field(alias="web_url")

    @field_validator("author", mode="before")
    @classmethod
    def get_author_username(cls, author_object):
        if isinstance(author_object, dict):
            return author_object.get("username")
        return author_object

    @field_validator("assignees", mode="before")
    @classmethod
    def get_assignees_usernames(cls, assignees_object):
        if isinstance(assignees_object, list):
            return [assignee.get("username") for assignee in assignees_object]
        return assignees_object

    @field_validator("reviewers", mode="before")
    @classmethod
    def get_reviewers_usernames(cls, reviewers_object):
        if isinstance(reviewers_object, list):
            return [reviewer.get("username") for reviewer in reviewers_object]
        return reviewers_object

    @field_validator("milestone", mode="before")
    @classmethod
    def get_milestone_title(cls, milestone_object):
        if isinstance(milestone_object, dict):
            return milestone_object.get("title")
        return milestone_object


class Project(BaseModel):
    id : int
    name : str
    description : str
    visibility : str
    open_issues : int = Field(alias="open_issues_count")
    url : str = Field(alias="web_url")


class Pipeline(BaseModel):
    id : int
#TODO! - Revisar cómo obtener el proyecto con la parte del front (¿desplegable con id del proyecto, que actualice el custom_config?)


class GitlabResponse(BaseModel):
    count: int
    items: list[Union[Issue, MergeRequest, Project, Pipeline]]

#TODO: Mejorar esto con https://pydantic.dev/docs/validation/latest/concepts/unions#discriminated-unions
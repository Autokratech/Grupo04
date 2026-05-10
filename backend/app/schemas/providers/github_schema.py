from pydantic import BaseModel, Field, field_validator
from typing import Union

# -- Responses
   
class Issue(BaseModel):
    id : int
    title : str
    state : str
    labels : list[str] | None = None #Revisar
    assignees : list[str] | None = None 
    milestone : str | None = None
    created_at : str
    due_date : str = Field(default=None, alias="due_date")
    url: str = Field(alias="html_url")

    @field_validator("labels", mode="before")
    @classmethod
    def get_label_names(cls, labels_object):
        if isinstance(labels_object, list):
            return [label.get("name") for label in labels_object]
        return labels_object

    @field_validator("assignees", mode="before")
    @classmethod
    def get_assignee_logins(cls, assignees_object):
        if isinstance(assignees_object, list):
            return [assignee.get("login") for assignee in assignees_object]
        return assignees_object

    @field_validator("milestone", mode="before")
    @classmethod
    def get_milestone_title(cls, milestone_object):
        if isinstance(milestone_object, dict):
            return milestone_object.get("title")
        return milestone_object
    

#TODO: Revisar! Todo vuelve dentro de ["items"] y hay que añadir un extra-step para obtener este valor en el caso de github
class MergeRequest(BaseModel):
    id : int
    title : str
    state : str
    source_branch : str | None = None #revisar, de momento puesta a none
    target_branch : str | None = None #revisar, de momento puesta a none
    author : str = Field(alias="user")
    labels : list[str] | None = None
    assignees : list[str] | None = None  
    reviewers : list[str] | None = None #No vienen en la llamada base, dependen del call intermedio
    milestone : str | None = None  #No viene en la llamada base, depende del call intermedio
    url: str = Field(alias="html_url") #Obtener dentro de pull_request, y es la url a la que hay que llamar para obtener source_branch y target_branch

    @field_validator("author", mode="before")
    @classmethod
    def get_author_login(cls, user_object):
        if isinstance(user_object, dict):
            return user_object.get("login")
        return user_object

    @field_validator("labels", mode="before")
    @classmethod
    def get_label_names(cls, labels_object):
        if isinstance(labels_object, list):
            return [label.get("name") for label in labels_object]
        return labels_object

    @field_validator("assignees", mode="before")
    @classmethod
    def get_assignee_logins(cls, assignees_object):
        if isinstance(assignees_object, list):
            return [assignee.get("login") for assignee in assignees_object]
        return assignees_object

    @field_validator("milestone", mode="before")
    @classmethod
    def get_milestone_title(cls, milestone_object):
        if isinstance(milestone_object, dict):
            return milestone_object.get("title")
        return milestone_object

class Project(BaseModel):
    id : int
    name : str
    description : str | None = None
    visibility : str
    open_issues : int = Field(alias="open_issues_count")
    url : str = Field(alias="html_url")


class Pipeline(BaseModel):
    id : int
#TODO! - Revisar cómo obtener el proyecto con la parte del front


class GitHubResponse(BaseModel):
    count: int
    items: list[Union[Issue, MergeRequest, Project, Pipeline]]

#TODO: Mejorar esto con https://pydantic.dev/docs/validation/latest/concepts/unions#discriminated-unions
from .dashboard_controller import (
    get_user_dashboard, create_dashboard, update_dashboard, delete_dashboard
)

from .oauth_controller import oauth_login, oauth_callback

from .tabs_controller import (
    get_dashboard_tabs, get_tab_by_id, get_tab_max_index, 
    create_tab, update_tab, delete_tab
)

from .widgets_controller import (
    get_widget, get_all_widgets, create_widget, update_widget, delete_widget
)

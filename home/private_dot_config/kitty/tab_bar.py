from kitty.fast_data_types import Screen
from kitty.tab_bar import (DrawData,
                           TabBarData,
                           ExtraData,
                           draw_tab_with_slant,
                           )


def draw_tab(
    draw_data: DrawData, screen: Screen, tab: TabBarData,
    before: int, max_title_length: int, index: int, is_last: bool,
    extra_data: ExtraData,
) -> int:

    layout_icon = "?"
    if tab.layout_name == "splits":
        layout_icon = " "
    elif tab.layout_name == "grid":
        layout_icon = "󰝘 "
    elif tab.layout_name == "vertical":
        layout_icon = " "
    elif tab.layout_name == "horizontal":
        layout_icon = " "
    elif tab.layout_name == "stack":
        layout_icon = " "

    new_draw_data = draw_data._replace(
        title_template=""
        + layout_icon
        + "{num_windows} "
        "{fmt.fg.yellow}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title} — {fmt.nobold}"
        + "{tab.active_wd}"
    )

    return draw_tab_with_slant(
        new_draw_data, screen, tab,
        before, max_title_length, index, is_last,
        extra_data)

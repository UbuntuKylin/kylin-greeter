
public class TestList : UserList
{
    public TestList (Background bg)
    {
        Object (background: bg);
    }

    public uint num_entries ()
    {
        return entries.length();
    }

    public bool is_scrolling ()
    {
        return mode == Mode.SCROLLING;
    }

}

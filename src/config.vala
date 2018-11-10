namespace Gtklash {
    void write_default_config(File file, bool exists) {
        FileIOStream io;
        if (exists) {
            io = file.open_readwrite();
        } else {
            io = file.create_readwrite(FileCreateFlags.NONE);
        }

        // TODO: Default config
        io.output_stream.write("port: 7890\n".data);
    }
}

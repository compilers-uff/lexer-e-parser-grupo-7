if [ $1 == "--build" ]; then
    mvn package
fi
if [ $1 == "--test" | $1 == "--build" ]; then
    java \
        -cp \
        "chocopy-ref.jar:target/assignment.jar" \
        chocopy.ChocoPy \
        --pass=s \
        --dir src/test/data/pa1/sample \
        --test
else
    java \
        -cp \
        "chocopy-ref.jar:target/assignment.jar" \
        chocopy.ChocoPy \
        --pass=s \
        --dir src/test/data/pa1/sample
fi

const fs = require('fs');
const readline = require('readline');

async function extractTests() {
    let testsFile = __dirname + '/testsToRun.txt';
    // Default: all tests
    await fs.promises.writeFile(testsFile, 'all');

    // Detect input source
    let inputFile = __dirname + '/comment_body.txt';
    if (!fs.existsSync(inputFile)) {
        inputFile = __dirname + '/pr_body.txt';
    }

    if (!fs.existsSync(inputFile)) {
        console.log('⚠️ No input file found, defaulting to all tests');
        return;
    }

    const lines = readline.createInterface({
        input: fs.createReadStream(inputFile),
        crlfDelay: Infinity
    });

    let collectedTests = [];
    let insideTestsSection = false;

    for await (const line of lines) {
        const trimmedLine = line.trim();

        // 🔹 New comment-based commands
        if (trimmedLine.startsWith('/run-tests ')) {
            let tests = trimmedLine.substring(11).trim();
            if (tests) {
                await fs.promises.writeFile(testsFile, tests);
                console.log(`✅ Detected test list from COMMENT (/run-tests): ${tests}`);
                return;
            }

        } else if (trimmedLine === '/run-all-tests') {
            await fs.promises.writeFile(testsFile, 'all');
            console.log('✅ Detected /run-all-tests in COMMENT → Running all tests');
            return;

        } else if (trimmedLine === '/run-affected-tests') {
            await fs.promises.writeFile(testsFile, 'all'); // placeholder
            console.log('✅ Detected /run-affected-tests in COMMENT → Defaulting to all for now');
            return;

        // 🔹 Legacy PR body format
        } else if (line.includes('Apex:[') && line.includes(']::Apex')) {
            let tests = line.substring(8, line.length - 7);
            await fs.promises.writeFile(testsFile, tests);
            console.log(`✅ Detected LEGACY Apex format in PR body → Running tests: ${tests}`);
            return;

        // 🔹 New structured PR body format
        } else if (/^Tests to run[:]?/i.test(trimmedLine)) {
            // Case 1: inline format → "Tests to run: Class1, Class2"
            let inlineTests = trimmedLine.split(':')[1]?.trim();
            if (inlineTests) {
                collectedTests.push(...inlineTests.split(/[, ]+/).filter(Boolean));
            }
            insideTestsSection = true;

        } else if (insideTestsSection) {
            // Case 2: bulleted list format
            if (trimmedLine.startsWith('-') || trimmedLine.startsWith('*')) {
                let testName = trimmedLine.replace(/^[-*]\s*/, '').trim();
                if (testName) collectedTests.push(testName);
            } else if (trimmedLine === '') {
                // Stop collecting if blank line reached
                insideTestsSection = false;
            }
        }
    }

    if (collectedTests.length > 0) {
        let tests = collectedTests.join(',');
        await fs.promises.writeFile(testsFile, tests);
        console.log(`✅ Detected STRUCTURED PR body format → Running tests: ${tests}`);
    } else {
        console.log('⚠️ No tests specified → Defaulting to ALL tests');
    }
}

extractTests().catch(console.error);

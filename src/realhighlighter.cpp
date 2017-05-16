/*****************************************************************************
 *
 * Created: 2016-2017 by Eetu Kahelin / eekkelund
 *
 * Copyright 2016-2017 Eetu Kahelin. All rights reserved.
 *
 * This file may be distributed under the terms of GNU Public License version
 * 3 (GPL v3) as defined by the Free Software Foundation (FSF). A copy of the
 * license should have been included with this file, or the project in which
 * this file belongs to. You may also find the details of GPL v3 at:
 * http://www.gnu.org/licenses/gpl-3.0.txt
 *
 * If you have any questions regarding the use of this file, feel free to
 * contact the author of this file, or the owner of the project in which
 * this file belongs to.
*****************************************************************************/
#include "realhighlighter.h"

#include <QtGui>


RealHighlighter::RealHighlighter(QTextDocument *parent): QSyntaxHighlighter(parent)
{
    commentStartExpression = QRegularExpression("/\\*");
    commentEndExpression = QRegularExpression("\\*/");

}
void RealHighlighter::loadDict(QString path, QStringList &patterns){
    QFile dict(path);
    if (dict.open(QIODevice::ReadOnly))
    {
        QTextStream textStream(&dict);
        while (true)
        {
            QString line = textStream.readLine();
            if (line.isNull())
                break;
            else
                patterns.append("\\b"+line+"\\b");
        }
        dict.close();
    }
}

void RealHighlighter::ruleUpdate()
{
    HighlightingRule rule;
    highlightingRules.clear();
    QStringList keywordPatterns;
    QStringList propertiesPatterns;

    // functionFormat.setFontItalic(true);
    functionFormat.setForeground(QColor(m_secondaryHighlightColor));
    rule.pattern = QRegularExpression("\\b[A-Za-z0-9_]+(?=\\()");
    rule.format = functionFormat;
    highlightingRules.append(rule);

    if (m_dictionary=="qml") {
        jsFormat.setForeground(QColor(m_secondaryHighlightColor));
        //jsFormat.setFontItalic(true);
        QStringList jsPatterns;
        loadDict(":/dictionaries/javascript.txt",jsPatterns);

        foreach (const QString &pattern, jsPatterns) {
            rule.pattern = QRegularExpression(pattern);
            rule.format = jsFormat;
            highlightingRules.append(rule);
        }

        qmlFormat.setForeground(QColor(m_highlightColor));
        qmlFormat.setFontWeight(QFont::Bold);
        QStringList qmlPatterns;
        loadDict(":/dictionaries/qml.txt",qmlPatterns);

        foreach (const QString &pattern, qmlPatterns) {
            rule.pattern = QRegularExpression(pattern);
            rule.format = qmlFormat;
            highlightingRules.append(rule);
        }

        keywordFormat.setForeground(QColor(m_highlightDimmerColor));
        keywordFormat.setFontWeight(QFont::Bold);

        loadDict(":/dictionaries/keywords.txt",keywordPatterns);

        foreach (const QString &pattern, keywordPatterns) {
            rule.pattern = QRegularExpression(pattern);
            rule.format = keywordFormat;
            highlightingRules.append(rule);
        }
        propertiesFormat.setForeground(QColor(m_primaryColor));
        propertiesFormat.setFontWeight(QFont::Bold);

        loadDict(":/dictionaries/properties.txt",propertiesPatterns);

        foreach (const QString &pattern, propertiesPatterns) {
            rule.pattern = QRegularExpression(pattern);
            rule.format = propertiesFormat;
            highlightingRules.append(rule);
        }
        //singleLineCommentFormat.setFontItalic(true);
        singleLineCommentFormat.setForeground(QColor(m_highlightBackgroundColor));
        rule.pattern = QRegularExpression("//[^\n]*");
        rule.format = singleLineCommentFormat;
        highlightingRules.append(rule);

        multiLineCommentFormat.setForeground(QColor(m_secondaryColor));

    }else if (m_dictionary=="py") {
        pythonFormat.setForeground(QColor(m_secondaryHighlightColor));
        //pythonFormat.setFontItalic(true);
        QStringList pythonPatterns;
        loadDict(":/dictionaries/python.txt",pythonPatterns);

        foreach (const QString &pattern, pythonPatterns) {
            rule.pattern = QRegularExpression(pattern);
            rule.format = pythonFormat;
            highlightingRules.append(rule);
        }

        singleLineCommentFormat.setForeground(QColor(m_highlightBackgroundColor));
        rule.pattern = QRegularExpression("#[^\n]*");
        rule.format = singleLineCommentFormat;
        highlightingRules.append(rule);

        keywordFormat.setForeground(QColor(m_highlightDimmerColor));
        keywordFormat.setFontWeight(QFont::Bold);
        loadDict(":/dictionaries/keywords.txt",keywordPatterns);

        foreach (const QString &pattern, keywordPatterns) {
            rule.pattern = QRegularExpression(pattern);
            rule.format = keywordFormat;
            highlightingRules.append(rule);
        }
    }else if (m_dictionary=="js") {
        jsFormat.setForeground(QColor(m_secondaryHighlightColor));
        //jsFormat.setFontItalic(true);
        QStringList jsPatterns;
        loadDict(":/dictionaries/javascript.txt",jsPatterns);

        foreach (const QString &pattern, jsPatterns) {
            rule.pattern = QRegularExpression(pattern);
            rule.format = jsFormat;
            highlightingRules.append(rule);
        }
        keywordFormat.setForeground(QColor(m_highlightDimmerColor));
        keywordFormat.setFontWeight(QFont::Bold);
        loadDict(":/dictionaries/keywords.txt",keywordPatterns);

        foreach (const QString &pattern, keywordPatterns) {
            rule.pattern = QRegularExpression(pattern);
            rule.format = keywordFormat;
            highlightingRules.append(rule);
        }
        //singleLineCommentFormat.setFontItalic(true);
        singleLineCommentFormat.setForeground(QColor(m_highlightBackgroundColor));
        rule.pattern = QRegularExpression("//[^\n]*");
        rule.format = singleLineCommentFormat;
        highlightingRules.append(rule);

        multiLineCommentFormat.setForeground(QColor(m_secondaryColor));

    }else if (m_dictionary=="sh") {
        bashFormat.setForeground(QColor(m_highlightColor));
        QStringList bashPatterns;
        loadDict(":/dictionaries/bash.txt", bashPatterns);

        foreach (const QString &pattern, bashPatterns) {
            rule.pattern = QRegularExpression(pattern);
            rule.format = bashFormat;
            highlightingRules.append(rule);
        }

        keywordFormat.setForeground(QColor(m_highlightDimmerColor));
        keywordFormat.setFontWeight(QFont::Bold);
        loadDict(":/dictionaries/keywords.txt",keywordPatterns);

        foreach (const QString &pattern, keywordPatterns) {
            rule.pattern = QRegularExpression(pattern);
            rule.format = keywordFormat;
            highlightingRules.append(rule);
        }

        singleLineCommentFormat.setForeground(QColor(m_highlightBackgroundColor));
        rule.pattern = QRegularExpression("#[^\n]*");
        rule.format = singleLineCommentFormat;
        highlightingRules.append(rule);

    }else{
        keywordFormat.setForeground(QColor(m_highlightDimmerColor));
        keywordFormat.setFontWeight(QFont::Bold);
        loadDict(":/dictionaries/keywords.txt",keywordPatterns);

        foreach (const QString &pattern, keywordPatterns) {
            rule.pattern = QRegularExpression(pattern);
            rule.format = keywordFormat;
            highlightingRules.append(rule);
        }
    }

    quotationFormat.setForeground(QColor(m_secondaryColor));
    //quotationFormat.setFontItalic(true);
    rule.pattern = QRegularExpression(R"**((?<!\\)([\"'])(.+?)(?<!\\)\1)**",QRegularExpression::DotMatchesEverythingOption | QRegularExpression::MultilineOption);
    rule.format = quotationFormat;
    highlightingRules.append(rule);

    numberFormat.setForeground(QColor(m_primaryColor));
    rule.pattern = QRegularExpression("[0-9]");
    rule.format = numberFormat;
    highlightingRules.append(rule);

}

void RealHighlighter::highlightBlock(const QString &text)
{
    foreach (const HighlightingRule &rule, highlightingRules) {
        QRegularExpression exp(rule.pattern);
        QRegularExpressionMatchIterator matches = exp.globalMatch(text);
        while (matches.hasNext()) {
            QRegularExpressionMatch match = matches.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }
    if(m_dictionary=="js" || m_dictionary=="qml"){
        setCurrentBlockState(0);

        int startIndex = 0;
        if (previousBlockState() != 1)
            startIndex = commentStartExpression.match(text).capturedStart();

        while (startIndex >= 0) {
            QRegularExpressionMatch m = commentEndExpression.match(text, startIndex);
            int endIndex = m.capturedStart();
            int commentLength;
            if (endIndex == -1) {
                setCurrentBlockState(1);
                commentLength = text.length() - startIndex;
            } else {
                commentLength = endIndex - startIndex + m.capturedLength();
            }
            setFormat(startIndex, commentLength, multiLineCommentFormat);
            startIndex = commentStartExpression.match(text, startIndex + commentLength).capturedStart();
        }
    }
}

void RealHighlighter::setStyle(QString primaryColor, QString secondaryColor, QString highlightColor, QString secondaryHighlightColor, QString highlightBackgroundColor, QString highlightDimmerColor, qreal baseFontPointSize)
{
    m_primaryColor = QString(primaryColor);
    m_secondaryColor = QString(secondaryColor);
    m_highlightColor = QString(highlightColor);
    m_secondaryHighlightColor = QString(secondaryHighlightColor);
    m_highlightBackgroundColor = QString(highlightBackgroundColor);
    m_highlightDimmerColor = QString(highlightDimmerColor);
    m_baseFontPointSize = baseFontPointSize;
    this->ruleUpdate();
    this->rehighlight();
}

void RealHighlighter::setDictionary(QString dictionary)
{
    m_dictionary = dictionary;
    this->ruleUpdate();
    this->rehighlight();
}

void RealHighlighter::searchHighlight(QString str)
{
    HighlightingRule rule;
    searchFormat.setBackground(QColor(m_highlightBackgroundColor));
    searchFormat.setFontItalic(true);
    searchFormat.setFontUnderline(true);
    rule.pattern = QRegularExpression(str,QRegularExpression::CaseInsensitiveOption);
    rule.format = searchFormat;
    highlightingRules.append(rule);
    this->rehighlight();
}

void RealHighlighter::enableHighlight(bool enable)
{
    if(enable) {
        this->ruleUpdate();
        this->rehighlight();
    } else {
        highlightingRules.clear();
        //HighlightingRule rule;
        //highlightingRules.append(rule);
        this->rehighlight();
    }
}


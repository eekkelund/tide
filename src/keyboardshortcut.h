/*****************************************************************************
 *
 * Created: 2017 by Eetu Kahelin / eekkelund
 *
 * Copyright 2017 Eetu Kahelin. All rights reserved.
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

#ifndef KEYBOARDSHORTCUT_H
#define KEYBOARDSHORTCUT_H

#include <QObject>
#include <QKeySequence>
#include <QVariant>

class KeyboardShortcut: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant key READ key WRITE setKey NOTIFY keyChanged)
public:
    explicit KeyboardShortcut(QObject *parent = 0);

    void setKey(QVariant key);
    QVariant key() { return m_keySequence; }

    bool eventFilter(QObject *obj, QEvent *e);

signals:
    void keyChanged();
    void activated();
    void pressedAndHold();

public slots:

private:
    QKeySequence m_keySequence;
    bool m_keypressAlreadySend;
};

#endif // KEYBOARDSHORTCUT_H
